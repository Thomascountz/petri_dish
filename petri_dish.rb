RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

module PetriDish
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
      metadata.start_time = Time.now if metadata.generation_count.zero?
      exit if metadata.generation_count >= configuration.max_generations
      # puts "\t\t\tGEN: #{metadata.generation_count.to_s.rjust(4, "0")}\tRUNTIME: #{sprintf("%.2f", Time.now - metadata.start_time)}s" if configuration.debug

      # Keep the top ~10% of the population
      elite_size = (configuration.population_size * 0.1).to_i
      elites = population.members.sort_by(&:fitness).last(elite_size)

      # Generate the rest of the next generation
      next_generation = (configuration.population_size - elite_size).times.map do
        child_member = configuration.crossover_function.call(population.select_parent, population.select_parent)
        configuration.mutation_function.call(child_member).tap do |mutated_child|
          if metadata.highest_fitness < mutated_child.fitness
            configuration.fittest_member_callback.call(mutated_child, metadata)
            metadata.highest_fitness = mutated_child.fitness
            # puts "FIT: #{mutated_child.fitness}\tGEN: #{metadata.generation_count.to_s.rjust(4, "0")}\tRUNTIME: #{sprintf("%.2f", Time.now - metadata.start_time)}s" if configuration.debug
          end
          exit if configuration.end_condition_function.call(mutated_child)
        end
      end

      # Include the elites in the next generation
      next_generation.concat(elites)

      new_population = Population.new(members: next_generation)
      metadata.increment_generation
      puts "#{metadata.generation_count},#{metadata.highest_fitness}" if configuration.debug
      run(population: new_population)
    end
  end

  class Population
    attr_reader :members

    def self.seed
      new(members: World.configuration.population_size.times.map { Member.new })
    end

    def initialize(members: nil)
      @members = members || []
    end

    def select_parent
      World.configuration.parent_selection_function.call(self)
    end
  end

  class Member
    attr_reader :genes

    def initialize(genes: nil)
      @genes = genes || World.configuration.gene_instantiation_function.call
    end

    def fitness
      @fitness ||= World.configuration.fitness_function.call(self)
    end

    def to_s
      genes.join("")
    end
  end

  class Metadata
    attr_reader :generation_count
    attr_accessor :highest_fitness, :start_time

    def initialize
      @generation_count = 0
      @highest_fitness = 0
      @start_time = nil
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
      :gene_instantiation_function,
      :parent_selection_function,
      :crossover_function,
      :mutation_function,
      :fitness_function,
      :end_condition_function,
      :fittest_member_callback,
      :debug

    # Default to lazy dog example
    def initialize
      @population_size = 100
      @mutation_rate = 0.005
      @genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
      @target_genes = "the quick brown fox jumped over the lazy white dog".chars
      @max_generations = 1
      @gene_instantiation_function = Configuration.random_gene_instantiation_function
      @fitness_function = Configuration.exponential_fitness_function
      @parent_selection_function = Configuration.twenty_percent_tournament_parent_selection_function
      @crossover_function = Configuration.random_midpoint_crossover_function
      @mutation_function = Configuration.random_mutation_function
      @end_condition_function = Configuration.genes_match_target_end_condition_function
      @fittest_member_callback = ->(member, _metadata) { puts member }
      @debug = false
    end

    class << self
      def random_gene_instantiation_function
        -> { Array.new(World.configuration.target_genes.size) { World.configuration.genetic_material.sample } }
      end

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

      def roulette_wheel_parent_selection_function
        ->(population) do
          population_fitness = population.members.sum(&:fitness)
          population.members.max_by do |member|
            weighted_fitness = member.fitness / population_fitness.to_f
            rand**(1.0 / weighted_fitness)
          end
        end
      end

      def twenty_percent_tournament_parent_selection_function
        ->(population) do
          population.members.sample(World.configuration.population_size * 0.2).max_by(&:fitness)
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
            (World.configuration.mutation_rate > rand) ? World.configuration.genetic_material.sample : gene
          end
          Member.new(genes: mutated_genes)
        end
      end

      def linear_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum
        end
      end

      def quadratic_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum**2
        end
      end

      def exponential_fitness_function
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum**3
        end
      end

      def genes_match_target_end_condition_function
        ->(member) do
          member.genes == World.configuration.target_genes
        end
      end
    end
  end
end
