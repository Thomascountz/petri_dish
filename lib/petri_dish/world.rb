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
      attr_reader :configuration, :end_condition_reached

      def run(
        members:,
        configuration: Configuration.new,
        metadata: Metadata.new
      )
        configuration.generation_start_callback&.call(metadata.generation_count)

        end_condition_reached = false
        max_generation_reached = false

        if metadata.generation_count.zero?
          configuration.logger.info({run_started: Time.now}.to_json)
          configuration.logger.info({population_size: configuration.population_size}.to_json)
          configuration.logger.info({mutation_rate: configuration.mutation_rate}.to_json)
          configuration.logger.info({elitism_rate: configuration.elitism_rate}.to_json)
          configuration.logger.info({max_generations: configuration.max_generations}.to_json)
          metadata.start
        end

        configuration.logger.info(metadata.to_json)

        if metadata.generation_count >= configuration.max_generations
          configuration.max_generation_reached_callback&.call
          max_generation_reached = true
        end

        elitism_count = (configuration.population_size * configuration.elitism_rate).round
        elite_members = members.sort_by(&:fitness).last(elitism_count)

        new_members = (configuration.population_size - elitism_count).times.map do
          child_member = configuration.crossover_function.call(configuration.parents_selection_function.call(members))

          configuration.mutation_function.call(child_member).tap do |mutated_child|
            if metadata.highest_fitness < mutated_child.fitness
              metadata.set_highest_fitness(mutated_child.fitness)
              configuration.highest_fitness_callback&.call(mutated_child)

              configuration.logger.info(metadata.to_json)
            end

            if configuration.end_condition_function&.call(mutated_child)
              configuration.end_condition_reached_callback&.call(mutated_child)
              end_condition_reached = true
            end
          end
        end

        metadata.increment_generation
        run(members: (new_members + elite_members), configuration: configuration, metadata: metadata) unless end_condition_reached || max_generation_reached
      end
    end
  end
end
