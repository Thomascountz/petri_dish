require "rspec"
require_relative "../lib/petri_dish/world"
require_relative "../lib/petri_dish/configuration"
require_relative "../lib/petri_dish/metadata"
require_relative "../lib/petri_dish/member"

RSpec.describe PetriDish::World do
  let(:members) { [double(PetriDish::Member, fitness: 0.1)] }
  let(:configuration) { instance_double(PetriDish::Configuration) }
  let(:metadata) { instance_double(PetriDish::Metadata) }

  before do
    allow(configuration).to receive(:logger).and_return(double("Logger", info: nil))
    allow(configuration).to receive(:max_generations).and_return(1)
    allow(configuration).to receive(:population_size).and_return(1)
    allow(configuration).to receive(:mutation_rate).and_return(0.005)
    allow(configuration).to receive(:elitism_rate).and_return(0.00)
    allow(configuration).to receive(:parents_selection_function).and_return(->(_members) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:crossover_function).and_return(->(_members) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:mutation_function).and_return(->(_member) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:end_condition_function).and_return(->(_member) { true })
    allow(configuration).to receive(:highest_fitness_callback).and_return(->(_member) { :noop })
    allow(configuration).to receive(:max_generation_reached_callback).and_return(-> { :noop })
    allow(configuration).to receive(:end_condition_reached_callback).and_return(->(_member) { :noop })
    allow(configuration).to receive(:generation_start_callback).and_return(->(_generation_count) { :noop })

    allow(metadata).to receive(:generation_count).and_return(0)
    allow(metadata).to receive(:highest_fitness).and_return(0.0)
    allow(metadata).to receive(:increment_generation)
    allow(metadata).to receive(:set_highest_fitness)
    allow(metadata).to receive(:start)
    allow(metadata).to receive(:to_json).and_return("{}")
  end

  context "when the generation count is zero" do
    it "starts the metadata" do
      allow(metadata).to receive(:generation_count).and_return(0)

      expect(metadata).to receive(:start)
      expect(described_class).to receive(:run).exactly(:once).and_call_original

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when max_generations is more than zero" do
    it "calls run recusively until generation_count reaches max_generations" do
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { false })
      allow(configuration).to receive(:max_generations).and_return(2)

      expect(described_class).to receive(:run).exactly(3).times.and_call_original

      described_class.run(members: members, configuration: configuration)
    end
  end

  context "on every recusive run" do
    it "calls generation_start_callback" do
      allow(configuration).to receive(:max_generations).and_return(5)
      allow(configuration).to receive(:generation_start_callback).and_return(generation_start_callback = ->(_generation_count) { :noop })
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { false })

      expect(generation_start_callback).to receive(:call).with(0).ordered
      expect(generation_start_callback).to receive(:call).with(1).ordered
      expect(generation_start_callback).to receive(:call).with(2).ordered
      expect(generation_start_callback).to receive(:call).with(3).ordered
      expect(generation_start_callback).to receive(:call).with(4).ordered
      expect(generation_start_callback).to receive(:call).with(5).ordered

      described_class.run(members: members, configuration: configuration)
    end
  end

  context "when the generation count reaches max generations" do
    it "calls max_generation_reached_callback" do
      allow(metadata).to receive(:generation_count).and_return(1)
      allow(configuration).to receive(:max_generations).and_return(1)
      allow(configuration).to receive(:max_generation_reached_callback).and_return(max_generation_reached_callback = -> { :noop })

      expect(max_generation_reached_callback).to receive(:call).once

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end

    it "stops the recursion" do
      allow(metadata).to receive(:generation_count).and_return(1)
      allow(configuration).to receive(:max_generations).and_return(1)

      expect(described_class).to receive(:run).exactly(:once).and_call_original

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when a child member has higher fitness value than the current highest fitness" do
    it "updates the highest fitness metadata" do
      current_highest_fitness = 1.0
      child_member_fitness = 2.0
      child_member = instance_double(PetriDish::Member, fitness: child_member_fitness)
      allow(configuration).to receive(:mutation_function).and_return(->(_member) { child_member })
      allow(metadata).to receive(:highest_fitness).and_return(current_highest_fitness)

      expect(metadata).to receive(:set_highest_fitness).with(child_member_fitness)

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end

    it "calls the highest_fitness_callback with the child member" do
      current_highest_fitness = 1.0
      child_member_fitness = 2.0
      child_member = instance_double(PetriDish::Member, fitness: child_member_fitness)
      allow(configuration).to receive(:mutation_function).and_return(->(_member) { child_member })
      allow(configuration).to receive(:highest_fitness_callback).and_return(highest_fitness_callback = ->(_member) { :noop })
      allow(metadata).to receive(:highest_fitness).and_return(current_highest_fitness)

      expect(highest_fitness_callback).to receive(:call).with(child_member)

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when creating new members" do
    it "creates a new members to fill in the next population" do
      population_size = 100
      elitism_rate = 0.2
      elite_count = 20
      new_members_count = population_size - elite_count

      allow(configuration).to receive(:population_size).and_return(population_size)
      allow(configuration).to receive(:elitism_rate).and_return(elitism_rate)

      expect(configuration).to receive(:crossover_function).exactly(new_members_count).times
      expect(configuration).to receive(:parents_selection_function).exactly(new_members_count).times

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when the end condition is met" do
    it "calls end_condition_reached_callback" do
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { true })
      end_condition_reached_callback = ->(_member) { :noop }
      allow(configuration).to receive(:end_condition_reached_callback).and_return(end_condition_reached_callback)

      expect(end_condition_reached_callback).to receive(:call).once

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when the end condition is met" do
    it "calls end_condition_reached_callback and stops the recursion" do
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { true })
      allow(configuration).to receive(:end_condition_reached_callback).and_return(->(_member) { :noop })

      expect(described_class).to receive(:run).exactly(:once).and_call_original

      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end
end
