require_relative "../lib/petri_dish"

target_genes = "the quick brown fox jumped over the lazy white dog".chars
genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]

def genes_match_target_end_condition_function
  ->(member) do
    member.genes == PetriDish::World.configuration.target_genes
  end
end

PetriDish::World.configure do |config|
  config.max_generations = 5000
  config.population_size = 250
  config.mutation_rate = 0.005
  config.genetic_material = genetic_material
  config.target_genes = target_genes
  config.gene_instantiation_function = -> { Array.new(target_genes.size) { genetic_material.sample } }
  config.parent_selection_function = PetriDish::GeneticOperatorUtils::Selection.twenty_percent_tournament
  config.fitness_function = PetriDish::GeneticOperatorUtils::Fitness.exponential
  config.crossover_function = PetriDish::GeneticOperatorUtils::Crossover.random_midpoint
  config.mutation_function = PetriDish::GeneticOperatorUtils::Mutation.random
  config.end_condition_function = genes_match_target_end_condition_function
  config.highest_fitness_callback = ->(member) { puts "Highest fitness: #{member.fitness} (#{member})" }
end

PetriDish::World.new.run
