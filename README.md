# Petri Dish - A Ruby library for Evolutionary Algorithms

> [!IMPORTANT]\
> The name of the gem is [`petri_dish_lab`](https://rubygems.org/gems/petri_dish_lab), _not_ `petri_dish`.

## Introduction

Welcome to Petri Dish, a Ruby library designed to provide an easy-to-use interface for implementing evolutionary algorithms. Petri Dish is a flexible library that allows you to configure and run your own evolutionary algorithms by simply providing your own genetic material, fitness function, and other parameters. This library is perfect for both beginners who are just starting to learn about evolutionary algorithms, and experts who want to experiment with different configurations and parameters.

## Overview of Evolutionary Algorithms

Evolutionary algorithms are a class of optimization algorithms that are inspired by the process of natural evolution. They work by maintaining a population of candidate solutions for the problem at hand and iteratively improving that population by applying operations that mimic natural evolution, such as mutation, crossover (or recombination), and selection.

The basic steps of an evolutionary algorithm are as follows:

1. **Initialization**: Begin with a population of randomly generated individuals.
2. **Evaluation**: Compute the fitness of each individual in the population.
3. **Selection**: Select individuals for reproduction based on their fitness.
4. **Crossover**: Generate offspring by combining the traits of selected individuals.
5. **Mutation**: Randomly alter some traits of the offspring.
6. **Replacement**: Replace the current population with the offspring.
7. **Termination**: If a termination condition is met (e.g., a solution of sufficient quality is found, or a maximum number of generations is reached), stop and return the best solution found. Otherwise, go back to step 2.

## Key Concepts of this Library

Petri Dish is built around a few key classes: `Configuration`, `Member`, `Metadata`, and `World`. 

- `Configuration`: This class provides a way to configure the behavior of the evolutionary algorithm. It exposes various parameters like `population_size`, `mutation_rate`, `genetic_material`, and several callback functions that can be used to customize the evolution process. 

- `Member`: This class represents an individual in the population. It has a set of genes and a fitness value, which is computed by a fitness function provided in the configuration.

- `Metadata`: This class keeps track of the evolution process, like the number of generations that have passed and the highest fitness value found so far.

- `World`: This class is responsible for running the evolutionary algorithm. It takes a configuration and a population of members as input, and runs the evolution process until a termination condition is met.

## Configuration

The `Configuration` class in Petri Dish allows you to customize various aspects of the evolutionary algorithm. Here are the parameters you can set:

Here is the reformatted list as a markdown table:

| Parameter | Description | Type |
|---|---|---|
| `logger` | An object that responds to `:info` for logging purposes | `Logger` |
| `population_size` | The number of individuals in the population | `Integer` |
| `mutation_rate` | The chance that a gene will change during mutation (between 0 and 1, inclusive) | `Float` |
| `genetic_material` | An array of possible gene values | `Array[untyped]` |
| `elitism_rate` | The proportion of the population preserved through elitism (between 0 and 1, inclusive) | `Float` |
| `target_genes` | The ideal set of genes for the problem at hand | `Array[untyped]` |
| `max_generations` | The maximum number of generations to run the evolution for | `Integer` |
| `parents_selection_function` | A function used to select parents for crossover | `Proc[Array[Member], Array[Member]]` |
| `crossover_function` | A function used to perform crossover between two parents | `Proc[Array[Member], Member]` |
| `mutation_function` | A function used to mutate the genes of an individual | `Proc[Member, Member]` |
| `fitness_function` | A function used to calculate the fitness of an individual | `Proc[Member, Numeric]` |
| `highest_fitness_callback` | A callback function invoked when a new highest fitness is found | `Proc[Member, void]` |
| `max_generation_reached_callback` | A callback function invoked when the maximum number of generations is reached | `Proc[void, void]` |
| `end_condition_function` | A function that determines whether the evolution process should stop premature of `max_generations` | `Proc[Member, bool]` |
| `next_generation_callback` | A callback function invoked at the start of each new generation | `Proc[void, void]` |
| `end_condition_reached_callback` | A callback function invoked when the end condition is met. It is called with the `Member` which triggered the `end_condition_function` | `Proc[Member, void]` |

You can create a new `Configuration` object by calling `Configuration.configure` and providing a block:

```ruby
configuration = PetriDish::Configuration.configure do |config|
  # set your configuration parameters here
end
```

In the block, you can set the parameters of the configuration to customize the behavior of your evolutionary algorithm.

## Member

The `Member` class in Petri Dish represents an individual in the population. Each member has a set of genes and a fitness value, which is calculated by a fitness function provided in the configuration. Here are the parameters and methods you can interact with:

- `new(genes:, fitness_function:)`: This method is used to create a new member. It takes an array of genes and a fitness function as arguments.

- `genes` (`Array[untyped]`): The genetic material of the individual, represented as an array .

- `fitness_function`  (`Proc[Member, Float]`): The function used to calculate the fitness of the individual. It is provided during the initialization of the member.

- `fitness`: This method calls the provided fitness function. The resulting fitness value is cached after the first calculation and reused in subsequent calls. 

Here's an example of how to create a new member:

```ruby
member = PetriDish::Member.new(
  genes: ["gene1", "gene2", "gene3"],
  fitness_function: ->(member) { # calculate fitness }
)
```

In this example, `["gene1", "gene2", "gene3"]` is the genetic material for the member, and the lambda function is used to calculate the fitness of the member. You should replace `# calculate fitness` with the actual logic for calculating fitness based on the problem you're trying to solve.

## Fitness Function

A fitness function is crucial as it provides a way to evaluate how good or "fit" an individual member of the population is in solving the problem at hand. The fitness function is a measure of quality or performance, and it guides the evolutionary algorithm in the search for optimal solutions.

Here are the necessary technical properties required when defining a fitness function for the Petri Dish framework:

1. Callable: The fitness function should be a callable object (for example, a lambda or a `Proc`). It should respond to `#call`.

2. Input: The fitness function should take a single argument, which is an instance of the `Member` class. This represents an individual member of the population whose fitness is to be evaluated.

3. Output: The fitness function should return a numerical value that represents the fitness of the given member. This could be an `Integer` or a `Float`, depending on the precision required. **Higher values should signify better fitness**.

4. Deterministic: Given the same `Member`, the fitness function should always return the same fitness score. This is because the fitness of a member may be evaluated multiple times during the evolutionary process, and inconsistent results could lead to unpredictable behavior.

5. Non-negative: The fitness function should ideally return non-negative values. This isn't a strict requirement, but having non-negative fitness values can make the algorithm easier to understand and debug.

6. Discriminative: The fitness function should be able to discriminate between different members of the population. That is, members with different genes should have different fitness scores. If many members have the same fitness score, the evolutionary algorithm will have a harder time deciding which members are better.

## Install and Setup

> [!WARNING]\
> The name of the _repo_ is `petri_dish`.\
> The name of the _module_ is `PetriDish`.\
> The name of the _gem_ is `petri_dish_lab`.

You can install `petri_dish_lab` as a gem in your application. Add this line to your application's Gemfile:

```ruby
gem 'petri_dish_lab'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install petri_dish_lab
```

At the top of your Ruby file, require the `petri_dish` _module_ name:

```ruby
require "petri_dish"
```

### Setup for Development

If you want to set up the `petri_dish_lab` gem for development, follow these steps:

1. Clone the repository:

```bash
git clone https://github.com/thomascountz/petri_dish.git
```

2. Change into the `petri_dish` directory:

```bash
cd petri_dish
```

3. Run the setup script:

```bash
bin/setup
```

This will install the necessary dependencies for development and testing.

### Using Console for Development

After setting up, you can use the development console to experiment with the `petri_dish` library:

```bash
bin/console
```

This will start an interactive Ruby session (IRB) with `PetriDish` pre-loaded. You can use this console to experiment with `PetriDish`, create `PetriDish::Member` instances, run evolutionary algorithms, etc.

Remember to run your tests frequently during development to ensure everything is working as expected:

```bash
bundle exec rspec
```

If you add new code, remember to add corresponding tests and ensure all tests pass before committing your changes.

## Examples

### Lazy Dog Example

The `lazy_dog_example.rb` is an example of using the Petri Dish library to solve a simple problem: Evolving a string to match "the quick brown fox jumped over the lazy white dog". This is a classic example of using a genetic algorithm to find a solution to a problem.

The genetic material in this case is the array of all lowercase letters and space. The target genes are the characters in the target string. The fitness function is defined as the cube of the sum of matches between the genes of a member and the target genes. This means that members with more matching characters will have a much higher fitness.

The parents for crossover are selected using a tournament selection function which picks the best 2 out of a random sample of 20% of the population. Crossover is performed at a random midpoint in the genes.

Mutation is implemented as a chance to replace a gene with a random gene from the genetic material. The mutation rate is set to 0.005, which means that on average, 0.5% of the genes in a member will mutate in each generation.

The end condition for the evolutionary process is when a member with genes exactly matching the target genes is found.

To run the example, simply execute the following command in your terminal:

```bash
bundle exec ruby examples/lazy_dog_example.rb
```

### Traveling Salesperson Example

The `salesperson_example.rb` is an example of using the Petri Dish library to solve a more complex problem: The Traveling Salesperson Problem. In this problem, a salesperson needs to visit a number of cities, each at a different location, and return to the starting city. The goal is to find the shortest possible route that visits each city exactly once.

In this example, each city is represented as a `Gene` object with `x` and `y` coordinates. The genetic material is the array of all possible `x` and `y` coordinates. The fitness function is defined as the inverse of the total distance of the route, which means that shorter routes will have higher fitness.

The parents for crossover are selected using a tournament selection function which picks the best 2 out of a random sample of 20% of the population. Crossover is performed using an ordered crossover method which maintains the relative order of the genes from both parents.

Mutation is implemented as a chance to swap two genes in a member. The mutation rate is set to 0.01, which means that on average, 1% of the genes in a member will mutate in each generation.

The evolutionary process runs for a fixed number of generations, and the highest fitness member in each generation is saved to a CSV file.

To run the example, simply execute the following command in your terminal:

```bash
bundle exec ruby examples/salesperson_example.rb
```

You can then visualize the best route using the provided `uplot` command.

## Resources
  - [Genetic Algorithms Explained By Example - Youtube](https://www.youtube.com/watch?v=uQj5UNhCPuo)
  - [Genetic Algorithms for Autonomous Robot Navigation - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.208.9941&rep=rep1&type=pdf)
  - [Nature of Code, Chapter 9 - The Evolution of Code - Book](https://natureofcode.com/book/chapter-9-the-evolution-of-code/)
  - [Weighted Random Sampling in Ruby - Gist](https://gist.github.com/O-I/3e0654509dd8057b539a)
  - [Tail Call Optimization in Ruby - Blog](https://nithinbekal.com/posts/ruby-tco/)
  - [Neural network and genetic algorithm based global path planning in a static environment - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.583.3340&rep=rep1&type=pdf)
  - [Traveling Salesman Problem using Genetic Algorithm - Blog](https://www.geeksforgeeks.org/traveling-salesman-problem-using-genetic-algorithm/)
  - [A KNOWLEDGE-BASED GENETIC ALGORITHM FOR PATH PLANNING OF MOBILE ROBOTS - Thesis](https://atrium.lib.uoguelph.ca/xmlui/bitstream/handle/10214/22039/Hu_Yanrong_MSc.pdf?sequence=2)
