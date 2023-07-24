module PetriDish
  class Population
    attr_reader :members, :configuration

    def self.seed(configuration)
      new(
        configuration: configuration,
        members: configuration.population_size.times.map { Member.new(configuration: configuration) }
      )
    end

    def initialize(configuration:, members: nil)
      @configuration = configuration
      @members = members || []
    end

    def select_parents
      configuration.parents_selection_function.call(self)
    end
  end
end
