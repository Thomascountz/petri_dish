module PetriDish
  class Metadata
    attr_reader :generation_count, :id, :start_time, :highest_fitness, :last_fitness_increase

    def initialize
      @id = SecureRandom.uuid
      @generation_count = 0
      @highest_fitness = 0
      @last_fitness_increase = 0
      @start_time = nil
    end

    def start
      @start_time = Time.now
    end

    def increment_generation
      @generation_count += 1
    end

    def set_highest_fitness(fitness)
      @highest_fitness = fitness
      @last_fitness_increase = generation_count
    end

    def to_h
      {
        id: id,
        generation_count: generation_count,
        highest_fitness: highest_fitness,
        elapsed_time: (Time.now - start_time).round(2),
        last_fitness_increase: last_fitness_increase
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
