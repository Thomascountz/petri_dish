module PetriDish
  class Member
    attr_reader :genes, :fitness_function

    def initialize(genes:, fitness_function:)
      @fitness_function = fitness_function
      @genes = genes
    end

    def fitness
      @fitness ||= fitness_function.call(self)
    end

    def to_s
      genes.join("")
    end
  end
end
