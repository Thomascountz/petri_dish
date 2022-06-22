module Petridish
  class World
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.metadata
      @metadata ||= Metadata.new
    end

    def configure
      yield configuration
    end

    def run(population = Population.seed)
      exit if World.metadata.generation_count >= World.configuration.max_generations
      next_generation = World.configuration.population_size.times.map do
        child_member = World.configuration.crossover_strategy.call(population.select_parent, population.select_parent)
        puts child_member.genes.join("")
        World.configuration.mutation_strategy.call(child_member)
      end
      new_population = Population.new(members: next_generation)
      World.metadata.increment_generation
      run(new_population)
    end
  end

  class Population
    attr_reader :members

    def self.seed
      new(members: World.configuration.population_size.times.map { Member.new })
    end

    def initialize(members: nil)
      @members = members || seed_population
    end

    def add_member(member)
      @members << member
    end

    def select_parent
      World.configuration.parent_selection_strategy.call(self)
    end
  end

  class Member
    attr_reader :genes

    def initialize(genes: nil)
      @genes = genes || Array.new(World.configuration.target_genes.size) { World.configuration.genetic_material.sample }
    end
  end

  class Metadata
    attr_reader :generation_count

    def initialize
      @generation_count = 0
    end

    def increment_generation
      @generation_count += 1
    end
  end

  class Configuration
    attr_accessor :population_size,
      :mutation_rate,
      :genetic_material,
      :target_genes,
      :max_generations,
      :parent_selection_strategy,
      :crossover_strategy,
      :mutation_strategy

    def initialize
      @population_size = 100
      @mutation_rate = 0.005
      @genetic_material = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
      @target_genes = "the quick brown fox jumped over the lazy white dog".chars
      @max_generations = 1
      @parent_selection_strategy = ->(population) do
        population.members.sample
      end
      @crossover_strategy = ->(a, b) do
        midpoint = target_genes.size / 2
        Member.new(genes: a.genes[0...midpoint] + b.genes[midpoint..])
      end
      @mutation_strategy = ->(member) do
        mutated_genes = member.genes.map do |gene|
          World.configuration.mutation_rate > rand ? World.configuration.genetic_material.sample : gene
        end
        Member.new(genes: mutated_genes)
      end
    end
  end
end
