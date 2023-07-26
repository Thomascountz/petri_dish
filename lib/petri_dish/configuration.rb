module PetriDish
  class Configuration
    attr_accessor :logger,
      :population_size,
      :mutation_rate,
      :genetic_material,
      :elitism_rate,
      :target_genes,
      :max_generations,
      :parents_selection_function,
      :crossover_function,
      :mutation_function,
      :fitness_function,
      :highest_fitness_callback,
      :max_generation_reached_callback,
      :end_condition_function,
      :generation_start_callback,
      :end_condition_reached_callback

    def self.configure
      yield(configuration = new)
      configuration.validate!
      configuration
    end

    def initialize
      @logger = default_logger
      @max_generations = default_max_generations
      @population_size = default_population_size
      @mutation_rate = default_mutation_rate
      @elitism_rate = default_elitism_rate
      @genetic_material = default_genetic_material
      @target_genes = default_target_genes
      @fitness_function = default_fitness_function
      @parents_selection_function = default_parents_selection_function
      @crossover_function = default_crossover_function
      @mutation_function = default_mutation_function
      @highest_fitness_callback = default_highest_fitness_callback
      @end_condition_function = default_end_condition_function
      @max_generation_reached_callback = default_max_generation_reached_callback
      @generation_start_callback = default_generation_start_callback
      @end_condition_reached_callback = default_end_condition_reached_callback
    end

    def validate!
      raise ArgumentError, "logger must respond to :info" unless logger.respond_to?(:info)
      raise ArgumentError, "max_generations must be greater than 0" unless max_generations > 0
      raise ArgumentError, "population_size must be greater than 0" unless population_size > 0
      raise ArgumentError, "mutation_rate must be between 0 and 1" unless mutation_rate >= 0 && mutation_rate <= 1
      raise ArgumentError, "elitism_rate must be between 0 and 1" unless elitism_rate >= 0 && elitism_rate <= 1
      raise ArgumentError, "genetic_material must be an Array" unless genetic_material.is_a?(Array)
      raise ArgumentError, "target_genes must be an Array" unless target_genes.is_a?(Array)
      raise ArgumentError, "fitness_function must respond to :call" unless fitness_function.respond_to?(:call)
      raise ArgumentError, "parents_selection_function must respond to :call" unless parents_selection_function.respond_to?(:call)
      raise ArgumentError, "crossover_function must respond to :call" unless crossover_function.respond_to?(:call)
      raise ArgumentError, "mutation_function must respond to :call" unless mutation_function.respond_to?(:call)
      raise ArgumentError, "end_condition_function must respond to :call" unless end_condition_function.respond_to?(:call)
      raise ArgumentError, "highest_fitness_callback must respond to :call" unless highest_fitness_callback.respond_to?(:call)
      raise ArgumentError, "max_generation_reached_callback must respond to :call" unless max_generation_reached_callback.respond_to?(:call)
      raise ArgumentError, "generation_start_callback must respond to :call" unless generation_start_callback.respond_to?(:call)
      raise ArgumentError, "end_condition_reached_callback must respond to :call" unless end_condition_reached_callback.respond_to?(:call)
    end

    def reset!
      @logger = default_logger
      @max_generations = default_max_generations
      @population_size = default_population_size
      @mutation_rate = default_mutation_rate
      @elitism_rate = default_elitism_rate
      @genetic_material = default_genetic_material
      @target_genes = default_target_genes
      @fitness_function = default_fitness_function
      @parents_selection_function = default_parents_selection_function
      @crossover_function = default_crossover_function
      @mutation_function = default_mutation_function
      @end_condition_function = default_end_condition_function
      @highest_fitness_callback = default_highest_fitness_callback
      @max_generation_reached_callback = default_max_generation_reached_callback
      @generation_start_callback = default_generation_start_callback
      @end_condition_reached_callback = default_end_condition_reached_callback
    end

    private

    def default_logger
      @logger = Logger.new($stdout).tap do |logger|
        logger.level = Logger::INFO
      end
    end

    def default_max_generations = 1

    def default_population_size = 100

    def default_mutation_rate = 0.005

    def default_elitism_rate = 0.00

    def default_genetic_material = []

    def default_target_genes = nil

    def default_fitness_function = ->(_member) { raise ArgumentError, "fitness_function must be set" }

    def default_parents_selection_function = ->(_members) { raise ArgumentError, "parents_selection_function must be set" }

    def default_crossover_function = ->(_members) { raise ArgumentError, "crossover_function must be set" }

    def default_mutation_function = ->(_member) { raise ArgumentError, "mutation_function must be set" }

    def default_end_condition_function = ->(_member) { false }

    def default_highest_fitness_callback = ->(_member) { :noop }

    # TODO: We might want to consider whether we really want to use `exit` as a
    # default callback. This will stop the entire Ruby process, which could be
    # surprising behavior if the user of the library doesn't override these
    # callbacks.
    def default_max_generation_reached_callback = -> { exit }

    def default_generation_start_callback = ->(_generation) { :noop }

    def default_end_condition_reached_callback = ->(_member) { exit }
  end
end
