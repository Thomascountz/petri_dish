RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

module Petridish
  class World
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.metadata
      @metadata ||= Metadata.new
    end

    def self.configure
      yield configuration
    end

    def self.run(population: Population.seed)
      exit if metadata.generation_count >= configuration.max_generations
      next_generation = configuration.population_size.times.map do
        child_member = configuration.crossover_function.call(population.select_parent, population.select_parent)
        configuration.mutation_function.call(child_member).tap do |mutated_child|
          if metadata.higest_fitness < mutated_child.fitness
            metadata.higest_fitness = mutated_child.fitness
            puts "#{mutated_child.genes.join("")}\tGEN: #{metadata.generation_count.to_s.rjust(4, "0")}"
          end
          exit if mutated_child.genes == configuration.target_genes
        end
      end
      new_population = Population.new(members: next_generation)
      metadata.increment_generation
      run(population: new_population)
    end
  end

  class Population
    attr_reader :members

    def self.seed
      new(members: World.configuration.population_size.times.map { Member.new })
    end

    def initialize(members: nil)
      @members = members || seed_population
    end

    def select_parent
      World.configuration.parent_selection_function.call(self)
    end
  end

  class Member
    attr_reader :genes

    def initialize(genes: nil)
      @genes = genes || Array.new(World.configuration.target_genes.size) { World.configuration.genetic_material.sample }
    end

    def fitness
      @fitness ||= World.configuration.fitness_function.call(self)
    end
  end

  class Metadata
    attr_reader :generation_count
    attr_accessor :higest_fitness

    def initialize
      @generation_count = 0
      @higest_fitness = 0
    end

    def increment_generation
      @generation_count += 1
    end
  end

  class Configuration
    attr_accessor :population_size,
      :mutation_rate,
      :genetic_material,
      :target_genes,
      :max_generations,
      :parent_selection_function,
      :crossover_function,
      :mutation_function,
      :fitness_function

    def initialize
      @population_size = 100
      @mutation_rate = 0.005
      @genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
      @target_genes = "the quick brown fox jumped over the lazy white dog".chars
      @max_generations = 1
      @fitness_function = Configuration.linear_fitness_function
      @parent_selection_function = Configuration.random_parent_selection_function
      @crossover_function = Configuration.midpoint_crossover_function
      @mutation_function = Configuration.random_mutation_function
    end

    class << self
      def random_parent_selection_function
        ->(population) do
          population.members.sample
        end
      end

      def elitist_fitness_parent_selection_function
        ->(population) do
          population.members.max_by(&:fitness)
        end
      end

      def probabilistically_fit_parent_selection_function
        ->(population) do
          population_fitness = population.members.sum(&:fitness)
          population.members.max_by do |member|
            weighted_fitness = member.fitness / population_fitness.to_f
            rand**(1.0 / weighted_fitness)
          end
        end
      end

      def midpoint_crossover_function
        ->(parent1, parent2) do
          midpoint = World.configuration.target_genes.size / 2
          Member.new(genes: parent1.genes[0...midpoint] + parent2.genes[midpoint..])
        end
      end

      def random_midpoint_crossover_function
        ->(parent1, parent2) do
          midpoint = rand(World.configuration.target_genes.size)
          Member.new(genes: parent1.genes[0...midpoint] + parent2.genes[midpoint..])
        end
      end

      def random_mutation_function
        ->(member) do
          mutated_genes = member.genes.map do |gene|
            World.configuration.mutation_rate > rand ? World.configuration.genetic_material.sample : gene
          end
          Member.new(genes: mutated_genes)
        end
      end

      def linear_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            target_gene == member_gene ? 1 : 0
          end.sum
        end
      end

      def quadratic_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            target_gene == member_gene ? 1 : 0
          end.sum**2
        end
      end

      def exponential_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            target_gene == member_gene ? 1 : 0
          end.sum**3
        end
      end
    end
  end
end
