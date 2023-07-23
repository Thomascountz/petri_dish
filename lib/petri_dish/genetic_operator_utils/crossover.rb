require_relative "../member"

module PetriDish
  module GeneticOperatorUtils
    class Crossover
      def self.random_midpoint
        ->(parent1, parent2) do
          midpoint = rand(parent1.genes.length)
          PetriDish::Member.new(genes: parent1.genes[0...midpoint] + parent2.genes[midpoint..])
        end
      end
    end
  end
end
