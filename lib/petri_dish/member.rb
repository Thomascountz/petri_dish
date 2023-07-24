module PetriDish
  class Member
    attr_reader :genes, :configuration

    def initialize(configuration:, genes: nil)
      @configuration = configuration
      @genes = genes || configuration.gene_instantiation_function.call
    end

    def fitness
      @fitness ||= configuration.fitness_function.call(self)
    end

    def to_s
      genes.join("")
    end
  end
end
