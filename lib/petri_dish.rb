RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

require "json"
require "logger"
require "securerandom"

require_relative "./petri_dish/configuration"
require_relative "./petri_dish/metadata"
require_relative "./petri_dish/member"
require_relative "./petri_dish/population"

module PetriDish
  class World
    class << self
      def configuration
        PetriDish::Configuration.instance
      end

      def configure
        yield(configuration)
      end

      def metadata
        @metadata ||= Metadata.new
      end
    end

    attr_accessor :metadata
    attr_reader :configuration

    def initialize(configuration: PetriDish::Configuration.instance, metadata: PetriDish::Metadata.new)
      @configuration = configuration
      @metadata = metadata
    end

    def run(population: PetriDish::Population.seed)
      startup if metadata.generation_count.zero?
      configuration.logger.info(metadata.to_json)
      configuration.max_generation_reached_callback.call if metadata.generation_count >= configuration.max_generations
      next_generation = configuration.population_size.times.map do
        child_member = configuration.crossover_function.call(population.select_parents)
        configuration.mutation_function.call(child_member).tap do |mutated_child|
          if metadata.highest_fitness < mutated_child.fitness
            metadata.highest_fitness = mutated_child.fitness
            configuration.logger.info(metadata.to_h.merge({updated_highest_fitness: true}).to_json)
            configuration.highest_fitness_callback.call(mutated_child)
          end
          configuration.end_condition_reached_callback.call(mutated_child) if configuration.end_condition_function.call(mutated_child)
        end
      end
      new_population = PetriDish::Population.new(members: next_generation)
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
