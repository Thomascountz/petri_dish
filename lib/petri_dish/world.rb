RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}

require "json"
require "logger"
require "securerandom"

require_relative "../petri_dish"

module PetriDish
  class World
    class << self
      attr_accessor :metadata
      attr_reader :configuration

      def run(
        configuration: Configuration.new,
        metadata: Metadata.new,
        population: PetriDish::Population.seed(configuration)
      )
        if metadata.generation_count.zero?
          configuration.logger.info "Run started."
          metadata.start_time = Time.now
        end
        configuration.logger.info(metadata.to_json)
        configuration.max_generation_reached_callback.call if metadata.generation_count >= configuration.max_generations
        elitism_count = (configuration.population_size * configuration.elitism_rate).round
        elite_members = population.members.sort_by(&:fitness).last(elitism_count)
        new_members = (configuration.population_size - elitism_count).times.map do
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
        new_population = PetriDish::Population.new(configuration: configuration, members: new_members + elite_members)
        metadata.increment_generation
        run(population: new_population, configuration: configuration, metadata: metadata)
      end
    end
  end
end
