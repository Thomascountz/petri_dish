require "bundler/inline"
require "stackprof"
require_relative "./petri_dish"

gemfile do
  source "https://rubygems.org"
  gem "rmagick", require: "rmagick"
  gem "pry"
end

Triangle = Data.define(
  :x1,
  :y1,
  :x2,
  :y2,
  :x3,
  :y3,
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

NUMBER_OF_GENERATIONS = 100
IMAGE_HEIGHT_PX = 100
IMAGE_WIDTH_PX = 100
GREYSCALE_VALUES = (0..255).to_a
POPULATION_SIZE = 200
MIN_MEMBER_SIZE = 100
MAX_MEMBER_SIZE = 500
MIN_RADIUS = 5
MAX_RADIUS = 10

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
  angles = 3.times.map { rand * 2 * Math::PI }

  points = angles.map do |angle|
    x = center_x + radius * Math.cos(angle)
    y = center_y + radius * Math.sin(angle)
    [x, y]
  end

  Triangle.new(
    x1: points[0][0], y1: points[0][1],
    x2: points[1][0], y2: points[1][1],
    x3: points[2][0], y3: points[2][1],
    grayscale: GREYSCALE_VALUES.sample
  )
end

def random_member
  Array.new(rand(MIN_MEMBER_SIZE..MAX_MEMBER_SIZE)) { random_triangle }
end

def import_image(path, output_path = "input_convert.png")
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

# import_image("astronaut.jpg")
# population = seed_population
# target_image = File.exist?("input_convert_500.png") ? Magick::Image.read("input_convert_500.png").first : import_image("astronaut.jpg", "input_convert_500.png")
target_image = File.exist?("input_convert_100.png") ? Magick::Image.read("input_convert_100.png").first : import_image("astronaut.jpg", "input_convert_100.png")

# Configuration for the genetic algorithm
PetriDish::World.configure do |config|
  config.population_size = POPULATION_SIZE
  config.mutation_rate = 0.1
  config.max_generations = NUMBER_OF_GENERATIONS
  config.target_genes = target_image
  config.gene_instantiation_function = -> { random_member }
  config.fitness_function = ->(member) { calculate_fitness(member.genes, config.target_genes) }
  config.parent_selection_function = PetriDish::Configuration.roulette_wheel_parent_selection_function
  config.crossover_function = ->(parent_1, parent_2) { random_midpoint_crossover_function(parent_1, parent_2) }
  config.mutation_function = ->(member) { random_mutation_function(member, config.mutation_rate) }
  config.fittest_member_callback = ->(member, metadata) { save_image(genes_to_image(member.genes, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX), "./out/output-#{metadata.generation_count}.png") }
  config.end_condition_function = ->(_member) { false } # Define your own end condition function
  config.precalculate_fitness_function = ->(population) { precalculate_fitness_parallel(population) }
  config.debug = true
end
target_image = PetriDish::World.configuration.target_genes

NUM_RACTORS = 4 # ::Etc.nprocessors / 3 # A third of the number of avaiable logical cores
RACTORS = (1..NUM_RACTORS).map do
  Ractor.new(target_image) do |target_image|
    loop do
      # Receive the member and target image
      genes = Ractor.receive

      # Calculate the fitness
      fitness = calculate_fitness(genes, target_image)

      # Send the member and its fitness back to the main Ractor
      Ractor.yield [genes, fitness]
    end
  end
end

def genes_to_image(genes, width, height)
  image = Magick::Image.new(width, height) { |options| options.background_color = "black" }
  draw = Magick::Draw.new
  genes.each do |triangle|
    draw.fill("rgb(#{triangle.grayscale}, #{triangle.grayscale}, #{triangle.grayscale})")
    draw.polygon(*triangle.vertices.flatten)
  end

  draw.draw(image)
  image
end

def save_image(image, path)
  image.write(path)
end

def precalculate_fitness_parallel(population)
  # Send the member and target image to each Ractor
  population.members.each_slice(population.members.size / NUM_RACTORS).with_index do |members, i|
    members.each do |member|
      genes = member.genes
      Ractor.make_shareable(genes)
      RACTORS[i].send(genes)
    end
  end

  # Receive all the fitnesses from the Ractors to create new Members and return a new Population
  genes_and_fitnesses = RACTORS.map { |ractor| ractor.take }

  new_members = genes_and_fitnesses.map do |(genes, fitness)|
    PetriDish::Member.new(genes: genes, fitness: fitness)
  end

  PetriDish::Population.new(members: new_members)
end

def calculate_fitness(genes, target_image)
  # Your code to generate an image from the member's genes (triangles)
  individual_image = genes_to_image(genes, IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX)

  # Compare the individual image to the target image
  _difference_image, difference = target_image.compare_channel(individual_image, Magick::MeanSquaredErrorMetric)

  # Use the mean error per pixel as the fitness
  1.0 / (difference + 0.0001) # The small constant in the denominator is to avoid division by zero
end

def random_midpoint_crossover_function(parent_1, parent_2)
  midpoint = (parent_1.genes.size <= parent_2.genes.size) ? rand(parent_1.genes.size) : rand(parent_2.genes.size)
  PetriDish::Member.new(genes: parent_1.genes[0...midpoint] + parent_2.genes[midpoint..])
end

def replace_mutation_function(member, mutation_rate)
  mutated_genes = member.genes.dup
  if PetriDish::World.configuration.mutation_rate > rand
    gene_index = rand(mutated_genes.size)
    mutated_genes[gene_index] = random_triangle
  end
  PetriDish::Member.new(genes: mutated_genes)
end

def random_mutation_function(member, mutation_rate)
  mutated_genes = member.genes.dup.map do |gene|
    (rand < mutation_rate) ? random_triangle : gene
  end
  PetriDish::Member.new(genes: mutated_genes)
end

# Start the genetic algorithm
# begin
# StackProf.run(mode: :cpu, raw: true, out: "./out/stackprof-cpu-myapp.dump") do
PetriDish::World.run
#   end
# rescue SystemExit, Interrupt
#   puts "Program exited early"
# end
