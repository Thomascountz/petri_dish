require_relative "../lib/petri_dish"
require_relative "../lib/petri_dish/genetic_operator_utils/selection"

XLIMIT = 10
YLIMIT = XLIMIT
NUM_OF_CITIES = 10

def random_uniq_city_gene_generation
  -> do
    result = []
    until result.size == NUM_OF_CITIES
      result << Gene.new(
        x: PetriDish::World.configuration.genetic_material.sample,
        y: PetriDish::World.configuration.genetic_material.sample
      )
      result.uniq!
    end
    result
  end
end

def random_gene_instantiation_function
  -> { PetriDish::World.configuration.target_genes.shuffle }
end

def fitness_function
  ->(member) do
    city_pairs = []
    member.genes.each_cons(2) { |cities| city_pairs << cities }
    # Return to the starting city
    city_pairs << [member.genes.last, member.genes.first]
    1.0 / city_pairs.sum { |a, b| a.distance_to(b) }
  end
end

def swap_mutation_function
  ->(member) do
    mutated_genes = member.genes.dup
    if PetriDish::World.configuration.mutation_rate > rand
      gene_one_index = rand(mutated_genes.size)
      gene_two_index = rand(mutated_genes.size)
      mutated_genes[gene_one_index], mutated_genes[gene_two_index] = mutated_genes[gene_two_index], mutated_genes[gene_one_index]
    end
    PetriDish::Member.new(genes: mutated_genes)
  end
end

# In ordered crossover, we randomly select a subset of the first
# parent string and then fill the remainder of the route with the
# genes from the second parent in the order in which they appear,
# without duplicating any genes in the selected subset from the
# first parent
def random_ordered_crossover_function
  ->(parents) do
    start_slice_index, end_slice_index = rand(parents[0].genes.size), rand(parents[0].genes.size)
    parent1_slice = parents[0].genes[start_slice_index...end_slice_index]
    parent2_contribution = parents[1].genes - parent1_slice
    child_genes = Array.new(parents[0].genes.size)
    child_genes[start_slice_index...end_slice_index] = parent1_slice
    child_genes.map! { |gene| gene.nil? ? parent2_contribution.shift : gene }
    PetriDish::Member.new(genes: child_genes)
  end
end

def write_best_member_to_file
  ->(member) do
    File.open("best_member.txt", "a") do |file|
      file.puts member.genes.join
    end
  end
end

class Gene
  attr_reader :x, :y
  def initialize(x: nil, y: nil)
    @x = x
    @y = y
  end

  def distance_to(other)
    Math.sqrt((x - other.x)**2 + (y - other.y)**2)
  end

  def to_s
    "(#{x}, #{y}),"
  end

  # Override equality methods
  def ==(other)
    x == other.x && y == other.y
  end

  def eql?(other)
    self == other
  end

  def hash
    [x, y].hash
  end
end

PetriDish::World.configure do |config|
  config.max_generations = 1000
  config.population_size = 100
  config.mutation_rate = 0.01
  config.genetic_material = (0..XLIMIT - 1).to_a
  config.target_genes = random_uniq_city_gene_generation.call
  config.gene_instantiation_function = random_gene_instantiation_function
  config.mutation_function = swap_mutation_function
  config.fitness_function = fitness_function
  config.parents_selection_function = PetriDish::GeneticOperatorUtils::Selection.twenty_percent_tournament
  config.crossover_function = random_ordered_crossover_function
  config.highest_fitness_callback = write_best_member_to_file
  # Rely on number of generations for end condition
  config.end_condition_function = ->(_member) { false }
end

PetriDish::World.new.run
