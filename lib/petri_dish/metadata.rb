module PetriDish
  class Metadata
    attr_reader :generation_count, :id
    attr_accessor :highest_fitness, :start_time

    def initialize
      @id = SecureRandom.uuid
      @generation_count = 0
      @highest_fitness = 0
      @start_time = nil
    end

    def increment_generation
      @generation_count += 1
    end

    def to_h
      {
        id: id,
        generation_count: generation_count,
        highest_fitness: highest_fitness,
        elapsed_time: (Time.now - start_time).round(2)
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
