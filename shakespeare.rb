POPULATION_SIZE = 100
MUTATION_RATE = 0.005
GENETIC_MATERIAL = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
TARGET_PHENOTYPE = "the quick brown fox jumped over the lazy white dog"
TARGET_GENOTYPE = TARGET_PHENOTYPE.chars

class Member
  attr_reader :genotype, :phenotype

  def initialize(genotype: nil)
    @genotype = genotype || Array.new(TARGET_PHENOTYPE.length) { GENETIC_MATERIAL.sample }
    @phenotype = @genotype.join
  end

  def to_s
    phenotype
  end

  def fitness
    @fitness ||= TARGET_GENOTYPE.zip(genotype).map do |target_gene, member_gene|
      target_gene == member_gene ? 1 : 0
    end.sum**5
  end

  def fitness_weight(population_fitness)
    fitness / population_fitness.to_f
  end
end

class Population
  attr_reader :members

  def initialize(members: nil)
    @members = members || seed_population
  end

  def seed_population
    Array.new(POPULATION_SIZE) { Member.new }
  end

  def fitness
    @fitness ||= members.map(&:fitness).sum
  end
end

class Runner
  class << self
    def run(population)
      @@generation ||= 0
      @@generation += 1
      @@current_best ||= population.members.first
      next_generation = Array.new(POPULATION_SIZE).map do
        a = probabilistically_fit_member(population)
        b = probabilistically_fit_member(population)
        child = reproduce(a, b)
        raise child.to_s if child.genotype == TARGET_GENOTYPE
        child
      end
    rescue => e
      puts "FOUND: \"#{e}\""
      puts "generation: #{@@generation}"
      puts "POPULATION SIZE: #{POPULATION_SIZE}"
      puts "MUTATION RATE: #{MUTATION_RATE}"
    else
      best = next_generation.max_by { |member| member.fitness }
      if @@current_best.fitness < best.fitness
        @@current_best = best
        puts "#{@@current_best}\tGEN: #{@@generation.to_s.rjust(4, "0")}"
      end
      next_population = Population.new(members: next_generation)
      # puts "#{@@generation},#{next_population.fitness}"
      run(next_population)
    end

    # https://gist.github.com/O-I/3e0654509dd8057b539a
    def probabilistically_fit_member(population)
      population.members.max_by do |member|
        rand**(1.0 / member.fitness_weight(population.fitness))
      end
    end

    def reproduce(a, b)
      midpoint = rand(TARGET_GENOTYPE.length)
      a_genetic_material = a.genotype[0...midpoint]
      b_genetic_material = b.genotype[midpoint..]
      child_genotype = mutate(a_genetic_material + b_genetic_material)
      Member.new(genotype: child_genotype)
    end

    def mutate(genotype)
      genotype.map do |gene|
        if rand <= MUTATION_RATE
          GENETIC_MATERIAL.sample
        else
          gene
        end
      end
    end
  end
end

# puts "generation,fitness"

RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: false
}
Runner.run(Population.new)
