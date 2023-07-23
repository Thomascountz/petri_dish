require_relative "../member"

module PetriDish
  module GeneticOperatorUtils
    class Crossover
      def self.random_midpoint
        ->(parents) do
          midpoint = rand(parents[0].genes.length)
          PetriDish::Member.new(genes: parents[0].genes[0...midpoint] + parents[1].genes[midpoint..])
        end
      end
    end
  end
end
