# require "petri_dish" # Uncomment this line and comment/remove the line below if you're using Petri Dish as a gem
require_relative "../../lib/petri_dish"

target_genes = "the quick brown fox jumped over the lazy white dog".chars
genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]

def genes_match_target_end_condition_function(target_genes)
  ->(member) do
    member.genes == target_genes
  end
end

def twenty_percent_tournament_function(configuration)
  ->(members) do
    members.sample(configuration.population_size * 0.2).max_by(2) { |member| member.fitness }
  end
end

def exponential_fitness_function(target_genes)
  ->(member) do
    member.genes.zip(target_genes).map do |target_gene, member_gene|
      (target_gene == member_gene) ? 1 : 0
    end.sum**3
  end
end

def random_midpoint_crossover_function(configuration)
  ->(parents) do
    midpoint = rand(parents[0].genes.length)
    PetriDish::Member.new(fitness_function: configuration.fitness_function, genes: parents[0].genes[0...midpoint] + parents[1].genes[midpoint..])
  end
end

def random_mutation_function(configuration)
  ->(member) do
    mutated_genes = member.genes.map do |gene|
      if rand < configuration.mutation_rate
        configuration.genetic_material.sample
      else
        gene
      end
    end
    PetriDish::Member.new(fitness_function: configuration.fitness_function, genes: mutated_genes)
  end
end

configuration = PetriDish::Configuration.configure do |config|
  config.logger = Logger.new("/dev/null")
  config.max_generations = 5000
  config.population_size = 250
  config.mutation_rate = 0.005
  config.genetic_material = genetic_material
  config.parents_selection_function = twenty_percent_tournament_function(config)
  config.fitness_function = exponential_fitness_function(target_genes)
  config.crossover_function = random_midpoint_crossover_function(config)
  config.mutation_function = random_mutation_function(config)
  config.end_condition_function = genes_match_target_end_condition_function(target_genes)
  config.highest_fitness_callback = ->(member) { puts "Highest fitness: #{member.fitness} (#{member})" }
end

init_members = Array.new(configuration.population_size) { PetriDish::Member.new(fitness_function: configuration.fitness_function, genes: Array.new(target_genes.size) { genetic_material.sample }) }
PetriDish::World.run(configuration: configuration, members: init_members)
