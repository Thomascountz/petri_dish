require_relative "../member"

module PetriDish
  module GeneticOperatorUtils
    module Mutation
      def self.random
        ->(member) do
          mutated_genes = member.genes.map do |gene|
            if rand < World.configuration.mutation_rate
              World.configuration.genetic_material.sample
            else
              gene
            end
          end
          Member.new(genes: mutated_genes)
        end
      end
    end
  end
end
