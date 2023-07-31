require_relative "../../lib/petri_dish"
require "bundler/inline"

$stdout.sync = true

gemfile do
  source "https://rubygems.org"
  gem "rmagick", require: "rmagick"
  gem "delaunator", require: true
end

LOW_POLY_RECONSTUCTION_PATH = "examples/low_poly_reconstruction".freeze
INPUT_IMAGE_PATH = "#{LOW_POLY_RECONSTUCTION_PATH}/ruby.svg".freeze
CONVERTED_INPUT_IMAGE_PATH = "#{LOW_POLY_RECONSTUCTION_PATH}/input_convert.png".freeze
OUT_DIR = "#{LOW_POLY_RECONSTUCTION_PATH}/out4".freeze
IMAGE_HEIGHT_PX = 100
IMAGE_WIDTH_PX = 100
GREYSCALE_VALUES = (0..255).to_a

class LowPolyImageReconstruction
  Point = Struct.new(:x, :y, :grayscale)

  def initialize
    @current_generation = 0
  end

  def run
    init_members = Array.new(configuration.population_size) do
      PetriDish::Member.new(
        genes: (0..IMAGE_WIDTH_PX).step(10).map do |x|
                 (0..IMAGE_HEIGHT_PX).step(10).map do |y|
                   Point.new(x + point_jitter, y + point_jitter, GREYSCALE_VALUES.sample)
                 end
               end.flatten,
        fitness_function: calculate_fitness(target_image)
      )
    end

    PetriDish::World.run(configuration: configuration, members: init_members)
  end

  def configuration
    PetriDish::Configuration.configure do |config|
      config.population_size = 50
      config.mutation_rate = 0.05
      config.elitism_rate = 0.05
      config.max_generations = 5000
      config.fitness_function = calculate_fitness(target_image)
      config.parents_selection_function = roulette_wheel_parent_selection_function
      config.crossover_function = random_midpoint_crossover_function(config)
      config.mutation_function = nudge_mutation_function(config)
      config.highest_fitness_callback = ->(member) { save_image(member_to_image(member, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX)) }
      config.generation_start_callback = ->(current_generation) { generation_start_callback(current_generation) }
      config.end_condition_function = nil
    end
  end

  # Introduce some randomness to the points due to the implementation of the
  # Delaunay algorithm leading to a divide by zero error when points are collinear
  def point_jitter
    jitter = 0.0001
    rand(-jitter..jitter)
  end

  def target_image
    @target_image ||= if File.exist?(CONVERTED_INPUT_IMAGE_PATH)
      Magick::Image.read(CONVERTED_INPUT_IMAGE_PATH).first
    else
      import_target_image(INPUT_IMAGE_PATH, CONVERTED_INPUT_IMAGE_PATH)
    end
  end

  def import_target_image(input_path, output_path)
    image = Magick::Image.read(input_path).first

    crop_size = [image.columns, image.rows].min
    crop_x = (image.columns - crop_size) / 2
    crop_y = (image.rows - crop_size) / 2

    image
      .crop(crop_x, crop_y, crop_size, crop_size)
      .resize(IMAGE_HEIGHT_PX, IMAGE_WIDTH_PX)
      .quantize(256, Magick::GRAYColorspace)
      .write(output_path)

    image
  end

  # This is a variant of the roulette wheel selection method, sometimes called stochastic acceptance.
  #
  # The method calculates the total fitness of the population and then, for each member,
  # it generates a random number raised to the power of the inverse of the member's fitness divided by the total fitness.
  # This gives a larger result for members with higher fitness.
  # The member with the highest result from this operation is selected.
  #
  # The method thus gives a higher chance of selection to members with higher fitness,
  # but also allows for the possibility of members with lower fitness being selected.
  def roulette_wheel_parent_selection_function
    ->(members) do
      population_fitness = members.sum(&:fitness)
      members.max_by(2) do |member|
        weighted_fitness = member.fitness / population_fitness.to_f
        rand**(1.0 / weighted_fitness)
      end
    end
  end

  def random_midpoint_crossover_function(configuration)
    ->(parents) do
      midpoint = rand(parents[0].genes.length)
      PetriDish::Member.new(genes: parents[0].genes[0...midpoint] + parents[1].genes[midpoint..], fitness_function: configuration.fitness_function)
    end
  end

  def nudge_mutation_function(configuration)
    ->(member) do
      mutated_genes = member.genes.dup.map do |gene|
        if rand < configuration.mutation_rate
          Point.new(
            gene.x + rand(-10..10) + point_jitter,
            gene.y + rand(-10..10) + point_jitter,
            (gene.grayscale + rand(-25..25)).clamp(0, 255)
          )
        else
          gene
        end
      end
      PetriDish::Member.new(genes: mutated_genes, fitness_function: configuration.fitness_function)
    end
  end

  def calculate_fitness(target_image)
    ->(member) do
      member_image = member_to_image(member, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX)
      # Difference is a tuple of [mean_error_per_pixel, normalized_mean_error, normalized_maximum_error]
      (1.0 / target_image.difference(member_image)[1])**2 # Use the mean error per pixel as the fitness
    end
  end

  def member_to_image(member, width, height)
    image = Magick::Image.new(width, height) { |options| options.background_color = "white" }
    draw = Magick::Draw.new

    # Perform Delaunay triangulation on the points
    # Delaunator.triangulate accepts a nested array of [[x1, y1], [xN, yN]]
    # coordinates and  returns an array of triangle vertex indices where each
    # group of three numbers forms a triangle
    triangles = Delaunator.triangulate(member.genes.map { |point| [point.x, point.y] })

    triangles.each_slice(3) do |i, j, k|
      # Get the vertices of the triangle
      triangle_points = member.genes.values_at(i, j, k)

      # Take the average color from all three points
      color = triangle_points.map(&:grayscale).sum / 3
      draw.fill("rgb(#{color}, #{color}, #{color})")

      # RMagick::Image#draw takes an array of vertices in the form [x1, y1,..., xN, yN]
      vertices = triangle_points.map { |point| [point.x, point.y] }
      draw.polygon(*vertices.flatten)
    end

    draw.draw(image)
    image
  end

  def save_image(image)
    image.write("#{OUT_DIR}/gen-#{@current_generation}.png")
  end

  def generation_start_callback(current_generation)
    @current_generation = current_generation
  end
end

LowPolyImageReconstruction.new.run
