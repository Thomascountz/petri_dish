module PetriDish
  module GeneticOperatorUtils
    class Selection
      def self.random = ->(population) { population.members.sample(2) }

      def self.elitist = ->(population) { population.members.max_by(2) { |member| member.fitness } }

      def self.roulette_wheel
        ->(population) do
          population_fitness = population.members.sum(&:fitness)
          population.members.max_by(2) do |member|
            weighted_fitness = member.fitness / population_fitness.to_f
            rand**(1.0 / weighted_fitness)
          end
        end
      end

      def self.twenty_percent_tournament
        ->(population) do
          population.members.sample(PetriDish::World.configuration.population_size * 0.2).max_by(2) { |member| member.fitness }
        end
      end
    end
  end
end
