RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

require "logger"
require "securerandom"
require "json"

module Petridish
  class World
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def metadata
        @metadata ||= Metadata.new
      end

      def configure
        yield configuration
      end

      def run(population: Population.seed)
        startup if metadata.generation_count.zero?
        configuration.logger.info(metadata.to_json)
        exit if metadata.generation_count >= configuration.max_generations
        next_generation = configuration.population_size.times.map do
          child_member = configuration.crossover_function.call(population.select_parent, population.select_parent)
          configuration.mutation_function.call(child_member).tap do |mutated_child|
            if metadata.highest_fitness < mutated_child.fitness
              metadata.highest_fitness = mutated_child.fitness
              configuration.logger.info(metadata.to_json)
              configuration.highest_fitness_callback.call(mutated_child)
            end
            exit if configuration.end_condition_function.call(mutated_child)
          end
        end
        new_population = Population.new(members: next_generation)
        metadata.increment_generation
        run(population: new_population)
      end

      private

      def startup
        configuration.logger.info "Run started."
        metadata.start_time = Time.now
      end
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
    attr_reader :generation_count, :id
    attr_accessor :highest_fitness, :start_time

    def initialize
      @id = SecureRandom.uuid
      @generation_count = 0
      @highest_fitness = 0
      @start_time = nil
    end

    def increment_generation
      @generation_count += 1
    end

    def to_json
      {
        id: id,
        generation_count: generation_count,
        highest_fitness: highest_fitness,
        elapsed_time: (Time.now - start_time).round(2)
      }.to_json
    end
  end

  class Configuration
    attr_accessor :logger,
      :population_size,
      :mutation_rate,
      :genetic_material,
      :target_genes,
      :max_generations,
      :gene_instantiation_function,
      :parent_selection_function,
      :crossover_function,
      :mutation_function,
      :fitness_function,
      :highest_fitness_callback,
      :end_condition_function

    # Default to lazy dog example
    def initialize
      @logger = Configuration.default_logger
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
      @highest_fitness_callback = Configuration.highest_fitness_member_stdout_callback
      @end_condition_function = Configuration.genes_match_target_end_condition_function
    end

    class << self
      def default_logger
        @logger = Logger.new($stdout).tap do |logger|
          logger.level = Logger::INFO
        end
      end

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

      def highest_fitness_member_stdout_callback
        ->(member) do
          puts "Highest fitness member: #{member}"
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
