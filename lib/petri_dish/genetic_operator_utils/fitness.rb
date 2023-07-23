module PetriDish
  module GeneticOperatorUtils
    class Fitness
      def self.linear
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum
        end
      end

      def self.quadratic
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum**2
        end
      end

      def self.exponential
        ->(member) do
          member.genes.zip(World.configuration.target_genes).map do |target_gene, member_gene|
            (target_gene == member_gene) ? 1 : 0
          end.sum**3
        end
      end
    end
  end
end