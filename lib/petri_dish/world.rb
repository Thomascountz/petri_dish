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
        members:,
        configuration: Configuration.new,
        metadata: Metadata.new,
        max_depth: 10000
      )
        return if max_depth.zero?
        if metadata.generation_count.zero?
          configuration.logger.info "Run started."
          metadata.start
        end
        configuration.logger.info(metadata.to_json)
        configuration.max_generation_reached_callback.call if metadata.generation_count >= configuration.max_generations

        elitism_count = (configuration.population_size * configuration.elitism_rate).round
        elite_members = members.sort_by(&:fitness).last(elitism_count)

        new_members = (configuration.population_size - elitism_count).times.map do
          child_member = configuration.crossover_function.call(configuration.parents_selection_function.call(members))

          configuration.mutation_function.call(child_member).tap do |mutated_child|
            if metadata.highest_fitness < mutated_child.fitness
              metadata.set_highest_fitness(mutated_child.fitness)
              configuration.logger.info(metadata.to_json)
              configuration.highest_fitness_callback.call(mutated_child)
            end

            # TODO: We might want to add a mechanism to break the recursion in
            # the if `end_condition_reached_callback` is called.  We could
            # achieve this by having the callbacks throw an exception or return
            # a special value that we check for to break the loop.
            configuration.end_condition_reached_callback.call(mutated_child) if configuration.end_condition_function.call(mutated_child)
          end
        end

        metadata.increment_generation
        run(members: (new_members + elite_members), configuration: configuration, metadata: metadata, max_depth: max_depth - 1)
      end
    end
  end
end
