require "singleton"

module PetriDish
  class Configuration
    include Singleton

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
      :max_generation_reached_callback,
      :end_condition_function,
      :end_condition_reached_callback

    class << self
      def default_logger
        @logger = Logger.new($stdout).tap do |logger|
          logger.level = Logger::INFO
        end
      end
    end

    def initialize
      @logger = Configuration.default_logger
      @max_generations = 1
      @population_size = 100
      @mutation_rate = 0.005
      @genetic_material = []
      @target_genes = nil
      @gene_instantiation_function = -> { raise ArgumentError, "gene_instantiation_function must be set" }
      @fitness_function = -> { raise ArgumentError, "fitness_function must be set" }
      @parent_selection_function = ->(_population) { raise ArgumentError, "parent_selection_function must be set" }
      @crossover_function = ->(_parent_1, parent_2) { raise ArgumentError, "crossover_function must be set" }
      @mutation_function = ->(_member) { raise ArgumentError, "mutation_function must be set" }
      @highest_fitness_callback = ->(_member) { :noop }
      @max_generation_reached_callback = -> { exit }
      @end_condition_function = ->(_member) { false }
      @end_condition_reached_callback = ->(_member) { exit }
    end
  end
end
