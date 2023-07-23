require_relative "../lib/petri_dish"

PetriDish::World.configure do |config|
  config.max_generations = 5000
  config.population_size = 250
  config.mutation_rate = 0.005
  config.genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
  config.target_genes = "the quick brown fox jumped over the lazy white dog".chars
  config.gene_instantiation_function = PetriDish::Configuration.random_gene_instantiation_function
  config.parent_selection_function = PetriDish::Configuration.twenty_percent_tournament_parent_selection_function
  config.fitness_function = PetriDish::Configuration.exponential_fitness_function
  config.crossover_function = PetriDish::Configuration.random_midpoint_crossover_function
end

PetriDish::World.run
