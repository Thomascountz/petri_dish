module PetriDish
  class Population
    attr_reader :members

    def self.seed
      new(members: World.configuration.population_size.times.map { Member.new })
    end

    def initialize(members: nil)
      @members = members || []
    end

    def select_parents
      World.configuration.parents_selection_function.call(self)
    end
  end
end