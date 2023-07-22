require "bundler/inline"
require_relative "./petri_dish"

gemfile do
  source "https://rubygems.org"
  gem "rmagick", require: "rmagick"
  gem "delaunator", require: true
  gem "pry"
end

Point = Struct.new(:x, :y, :grayscale)

Triangle = Data.define(
  :x1,
  :y1,
  :x2,
  :y2,
  :x3,
  :y3,
  :z_index,
  :grayscale
) do
  def vertices
    [
      [x1, y1],
      [x2, y2],
      [x3, y3]
    ]
  end
end

NUMBER_OF_GENERATIONS = 1000
IMAGE_HEIGHT_PX = 250
IMAGE_WIDTH_PX = 250
IMAGE_MAX_Z_INDEX = 100
GREYSCALE_VALUES = (0..255).to_a
POPULATION_SIZE = 100
MIN_MEMBER_SIZE = 100
MAX_MEMBER_SIZE = 250
MIN_RADIUS = 2
MAX_RADIUS = 15

# Introduce some randomness to the points due to the implementation of the
# algorithm leading to a divide by zero error when points are collinear
def point_jitter
  jitter = 0.0001
  rand(-jitter..jitter)
end

def random_point
  Point.new(rand(IMAGE_WIDTH_PX) + point_jitter, rand(IMAGE_HEIGHT_PX) + point_jitter, GREYSCALE_VALUES.sample)
end

def random_triangle
  # Choose a random point within the image
  center_x, center_y = rand(IMAGE_WIDTH_PX), rand(IMAGE_HEIGHT_PX)

  # Create a circle around the point with a random radius
  radius = rand(MIN_RADIUS..MAX_RADIUS)

  # Choose three random points on the circle's circumference. `rand * 2 *
  # Math::PI1 gives a random angle in the range `0` to `2 * Math::PI` radians,
  # i.e., anywhere around the full circumference of the circle.  Then, given the
  # angle and the radius, we can find the coordinates `(x, y)` on the circle by
  # using the formulas `x = center_x + radius * Math.cos(angle)` and `y =
  # center_y + radius * Math.sin(angle)`. These are basically the conversion
  # formulas from polar to Cartesian coordinates.
  points = Array.new(3) do
    angle = rand * 2 * Math::PI
    [(center_x + radius * Math.cos(angle)), (center_y + radius * Math.sin(angle))]
  end

  Triangle.new(
    x1: points[0][0], y1: points[0][1],
    x2: points[1][0], y2: points[1][1],
    x3: points[2][0], y3: points[2][1],
    z_index: rand(IMAGE_MAX_Z_INDEX),
    grayscale: GREYSCALE_VALUES.sample
  )
end

# def random_member
#   Array.new(rand(MIN_MEMBER_SIZE..MAX_MEMBER_SIZE)) { random_triangle }
# end

def random_member
  Array.new(rand(MIN_MEMBER_SIZE..MAX_MEMBER_SIZE)) { random_point }
end

def import_image(path, output_path = "target_image.png")
  image = Magick::Image.read(path).first

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

target_image = File.exist?("input_convert_#{IMAGE_HEIGHT_PX}.png") ? Magick::Image.read("input_convert_#{IMAGE_HEIGHT_PX}.png").first : import_image("astronaut.jpg", "input_convert_#{IMAGE_HEIGHT_PX}.png")

# Configuration for the genetic algorithm
PetriDish::World.configure do |config|
  config.population_size = POPULATION_SIZE
  config.mutation_rate = 0.01
  config.max_generations = NUMBER_OF_GENERATIONS
  config.target_genes = target_image
  config.gene_instantiation_function = -> { random_member }
  config.fitness_function = ->(member) { calculate_fitness_difference(member, config.target_genes) }
  config.parent_selection_function = PetriDish::Configuration.roulette_wheel_parent_selection_function
  config.crossover_function = ->(parent_1, parent_2) { random_midpoint_crossover_function(parent_1, parent_2) }
  config.mutation_function = ->(member) { random_mutation_function(member, config.mutation_rate) }
  config.fittest_member_callback = ->(member, metadata) { save_image(member_to_image(member, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX), "./out7/gen-#{metadata.generation_count}.png") }
  # config.next_generation_callback = ->(population, metadata) { puts "Generation #{metadata.generation_count} fittest member: #{population.fittest_member}" },
  config.end_condition_function = ->(_member) { false } # Define your own end condition function
  config.debug = true
end

# def member_to_image(member, width, height)
#   image = Magick::Image.new(width, height) { |options| options.background_color = "black" }
#   draw = Magick::Draw.new
#   member.genes.sort_by(&:z_index).each do |triangle|
#     draw.fill("rgb(#{triangle.grayscale}, #{triangle.grayscale}, #{triangle.grayscale})")
#     draw.polygon(*triangle.vertices.flatten)
#   end
#   draw.draw(image)
#   image
# end

def member_to_image(member, width, height)
  image = Magick::Image.new(width, height) { |options| options.background_color = "black" }
  draw = Magick::Draw.new

  # Get the points from the member
  points = member.genes.map { |point| [point.x, point.y] }

  # Perform Delaunay triangulation on the points
  triangles = Delaunator.triangulate(points)

  # Draw each triangle
  triangles.each_slice(3) do |i, j, k|
    # Get the vertices of the triangle
    vertices = [points[i], points[j], points[k]]

    # Get the color of the triangle
    # Here we take the color from the first point of the triangle.
    # You might want to adjust this depending on your specific setup.
    color = member.genes[i].grayscale
    draw.fill("rgb(#{color}, #{color}, #{color})")

    draw.polygon(*vertices.flatten)
  end

  draw.draw(image)
  image
end

def save_image(image, path)
  image.write(path)
end

def calculate_fitness(member, target_image)
  individual_image = member_to_image(member, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX)

  # `Image#compare_channel` compares a particular channel (color component)
  _difference_image, difference = target_image.compare_channel(individual_image, Magick::MeanSquaredErrorMetric, Magick::LuminosityChannel)

  # Use the mean error per pixel as the fitness
  1.0 / (difference + 0.0001) # The small constant in the denominator is to avoid division by zero
end

def calculate_fitness_difference(member, target_image)
  # Your code to generate an image from the member's genes (triangles)
  individual_image = member_to_image(member, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX)
  # Difference is a tuple of [mean_error_per_pixel, normalized_mean_error, normalized_maximum_error]
  # (1.0 - target_image.difference(individual_image)[2])**2
  1.0 / target_image.difference(individual_image)[1]**2
end

def random_midpoint_crossover_function(parent_1, parent_2)
  midpoint = (parent_1.genes.size <= parent_2.genes.size) ? rand(parent_1.genes.size) : rand(parent_2.genes.size)
  PetriDish::Member.new(genes: parent_1.genes[0...midpoint] + parent_2.genes[midpoint..])
end

def replace_mutation_function(member, mutation_rate)
  mutated_genes = member.genes.dup
  if PetriDish::World.configuration.mutation_rate > rand
    gene_index = rand(mutated_genes.size)
    mutated_genes[gene_index] = random_trandom_
  end
  PetriDish::Member.new(genes: mutated_genes)
end

def random_mutation_function(member, mutation_rate)
  mutated_genes = member.genes.dup.map do |gene|
    (rand < mutation_rate) ? random_point : gene
  end
  PetriDish::Member.new(genes: mutated_genes)
end

# Start the genetic algorithm
$stdout.sync = true
puts "generation,fitness" if PetriDish::World::configuration.debug
PetriDish::World.run
