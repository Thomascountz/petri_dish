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
    allow(configuration).to receive(:genetic_material).and_return([])
    allow(configuration).to receive(:parents_selection_function).and_return(->(_members) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:crossover_function).and_return(->(_members) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:mutation_function).and_return(->(_member) { double(PetriDish::Member, fitness: 0.1) })
    allow(configuration).to receive(:end_condition_function).and_return(->(_member) { true })
    allow(configuration).to receive(:highest_fitness_callback).and_return(->(_member) { :noop })
    allow(configuration).to receive(:max_generation_reached_callback).and_return(-> { :noop })
    allow(configuration).to receive(:end_condition_reached_callback).and_return(->(_member) { :noop })

    allow(metadata).to receive(:generation_count).and_return(0)
    allow(metadata).to receive(:highest_fitness).and_return(0.0)
    allow(metadata).to receive(:increment_generation)
    allow(metadata).to receive(:set_highest_fitness)
    allow(metadata).to receive(:start)
    allow(metadata).to receive(:to_json).and_return("{}")
  end

  context "when the generation count is zero" do
    it "logs the start of the run and starts the metadata" do
      expect(configuration.logger).to receive(:info).with("Run started.")
      expect(metadata).to receive(:start)
      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when the generation count reaches max generations" do
    it "calls max_generation_reached_callback and stops the recursion" do
      allow(metadata).to receive(:generation_count).and_return(1)
      allow(configuration).to receive(:max_generation_reached_callback).and_return(-> { :noop })
      expect(described_class).to receive(:run).once.and_call_original
      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when a child member has higher fitness than the highest fitness" do
    it "updates the highest fitness and calls highest_fitness_callback" do
      allow(configuration).to receive(:mutation_function).and_return(->(_member) { double(PetriDish::Member, fitness: 1.0) })
      expect(metadata).to receive(:set_highest_fitness).with(1.0)
      expect(configuration).to receive(:highest_fitness_callback).and_return(->(_member) { :noop })
      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "when the end condition is met" do
    it "calls end_condition_reached_callback and stops the recursion" do
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { true })
      allow(configuration).to receive(:end_condition_reached_callback).and_return(->(_member) { :noop })
      expect(described_class).to receive(:run).once.and_call_original
      described_class.run(members: members, configuration: configuration, metadata: metadata)
    end
  end

  context "with recursion" do
    it "calls run again with updated members, configuration, and metadata" do
      allow(configuration).to receive(:end_condition_function).and_return(->(_member) { false })
      allow(configuration).to receive(:max_generations).and_return(2)
      expect(described_class).to receive(:run).thrice.and_call_original
      described_class.run(members: members, configuration: configuration)
    end
  end
end
