module PetriDish
  class Member
    attr_reader :genes

    def initialize(genes: nil)
      @genes = genes || World.configuration.gene_instantiation_function.call
    end

    def fitness
      @fitness ||= World.configuration.fitness_function.call(self)
    end

    def to_s
      genes.join("")
    end
  end
end
