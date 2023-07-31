# Petri Dish - A Ruby library for Evolutionary Algorithms

> [!IMPORTANT]\
> The name of the gem is [`petri_dish_lab`](https://rubygems.org/gems/petri_dish_lab), _not_ `petri_dish`.

## Introduction

Welcome to Petri Dish, a Ruby library designed to provide a flexible interface for implementing evolutionary algorithms. Petri Dish allows you to configure and run your own evolutionary algorithms by providing configurations for genetic material, fitness function, and other parameters. This library is aimed at experimenting with various configurations of evolutionary algorithms and is not meant for production.

## Overview of Evolutionary Algorithms

Evolutionary algorithms are a class of optimization algorithms that are inspired by the process of natural evolution. They work by maintaining a population of candidate solutions for a specific problem and iteratively evolving that population by applying operations that mimic natural evolution, such as mutation, crossover (or recombination), and selection.

The high-level steps of an evolutionary algorithm are:

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

- `Metadata`: This class keeps track of the evolution process, like the number of generations that have passed and the highest fitness value found so far. Metadata isn't exposed publically.

- `World`: This class is responsible for running the evolutionary algorithm. It takes a configuration and a population of members as input, and runs the evolution process recursively until a termination condition is met.

## Configuration

The `Configuration` class in Petri Dish allows you to customize various aspects of the evolutionary algorithm. Here are the parameters you can set:

| Parameter                         | Description                                                                                                                            | RBS Type Description                 |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| `logger`                          | An object that responds to `:info` for logging purposes                                                                                | `Logger`                             |
| `population_size`                 | The number of individuals in the population                                                                                            | `Integer`                            |
| `mutation_rate`                   | The chance that a gene will change during mutation (between 0 and 1, inclusive)                                                        | `Float`                              |
| `genetic_material`                | An array of possible gene values                                                                                                       | `Array[untyped]`                     |
| `elitism_rate`                    | The proportion of the population preserved through elitism (between 0 and 1, inclusive)                                                | `Float`                              |
| `max_generations`                 | The maximum number of generations to run the evolution for                                                                             | `Integer`                            |
| `parents_selection_function`      | A function used to select parents for crossover                                                                                        | `Proc[Array[Member], Array[Member]]` |
| `crossover_function`              | A function used to perform crossover between two parents                                                                               | `Proc[Array[Member], Member]`        |
| `mutation_function`               | A function used to mutate the genes of an individual                                                                                   | `Proc[Member, Member]`               |
| `fitness_function`                | A function used to calculate the fitness of an individual                                                                              | `Proc[Member, Numeric]`              |
| `highest_fitness_callback`        | A callback function invoked when a new highest fitness is found                                                                        | `nil \| Proc[Member, void]`                 |
| `max_generation_reached_callback` | A callback function invoked when the maximum number of generations is reached                                                          | `nil \| Proc[void, void]`                   |
| `end_condition_function`          | A function that determines whether the evolution process should stop premature of `max_generations`                                    | `nil \| Proc[Member, bool]`                 |
| `generation_start_callback`       | A callback function invoked at the start of each new generation                                                                        | `nil \| Proc[Integer, void]`                   |
| `end_condition_reached_callback`  | A callback function invoked when the end condition is met. It is called with the `Member` which triggered the `end_condition_function` | `nil \| Proc[Member, void]`                 |

You can create a new `Configuration` object by calling `Configuration.configure` and providing a block:

```ruby
configuration = PetriDish::Configuration.configure do |config|
  config.logger = Logger.new($stdout)
  config.population_size = 100
  # ...cont
end
```

## Member

The `Member` class in Petri Dish represents an individual in the population. Each member has a set of genes and a fitness value, which is calculated by a fitness function provided in the configuration. Here are the parameters and methods you can interact with:

- `Member#new(genes:, fitness_function:)`: This method is used to create a new member. It takes an array of genes and a fitness function as arguments.
  
- `Member#genes` (`Array[untyped]`): The genetic material of the individual, represented as an array.
  
- `Configuration#fitness_function`: (`Proc[Member, Float]`): The function used to calculate the fitness of the individual. It is provided during the initialization of the member.
  
- `Member#fitness`: This method calls the provided fitness function. The resulting fitness value is cached after the first calculation and reused in subsequent calls. 


Here's an example of how to create a new member:

```ruby
member = PetriDish::Member.new(
  genes: [1, 1, 0, 1, 0, 1],
  fitness_function: ->(member) { member.genes.sum }
)
```

In this example, `[1, 1, 0, 1, 0, 1]` is the genetic material for the member, and the lambda function is used to calculate the fitness of the member (in this example, we take the sum of the Array).

## Fitness Function

Modelling a meaningful fitness function is crucial as it provides a way to evaluate how good or "fit" an individual member of the population is in solving the problem at hand. The fitness function is a measure of quality or performance, and it guides the evolutionary algorithm in the search for optimal solutions.

Here are the necessary technical properties required when defining a fitness function for the Petri Dish framework:

1. Callable: The fitness function should be a callable object (for example, a lambda or a `Proc`). It should respond to `#call`.

2. Input: The fitness function should take a single argument, which is an instance of the `Member` class. This represents an individual member of the population whose fitness is to be evaluated.

3. Output: The fitness function should return a numerical value that represents the fitness of the given member. This could be an `Integer` or a `Float`, depending on the precision required. **Higher values should signify better fitness**.

4. Deterministic: Given the same `Member`, the fitness function should always return the same fitness score. This is because the fitness of a member may be evaluated multiple times during the evolutionary process, and inconsistent results could lead to unpredictable behavior.

5. Discriminative: The fitness function should be able to discriminate between different members of the population. That is, members with different genes should have different fitness scores. If many members have the same fitness score, the evolutionary algorithm will have a harder time deciding which members are better.

6. Non-negative: The fitness function should ideally return non-negative values. This isn't a strict requirement, but having non-negative fitness values can make the algorithm easier to understand and debug.

## Install and Setup

> [!WARNING]\
> The name of the _gem_ is `petri_dish_lab`. \
> The name of the _repo_ is `petri_dish`. \
> The name of the _module_ is `PetriDish`.

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

Several example problems are configured and solved in the `/examples` directory.

- [Lazy Dog](examples/lazy_dog/README.md) - Evolving a string to match "the quick brown fox jumped over the lazy white dog"
- [Traveling Salesperson](examples/traveling_salesperson/README.md) - Finding the shortest route that visits each city exactly once
- [Low-Poly Image Reconstruction](examples/low_poly_reconstruction/README.md) - Generating a low-poly representation of an image


## Resources
  - [Genetic Algorithms Explained By Example - Youtube](https://www.youtube.com/watch?v=uQj5UNhCPuo)
  - [Genetic Algorithms for Autonomous Robot Navigation - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.208.9941&rep=rep1&type=pdf)
  - [Nature of Code, Chapter 9 - The Evolution of Code - Book](https://natureofcode.com/book/chapter-9-the-evolution-of-code/)
  - [Weighted Random Sampling in Ruby - Gist](https://gist.github.com/O-I/3e0654509dd8057b539a)
  - [Tail Call Optimization in Ruby - Blog](https://nithinbekal.com/posts/ruby-tco/)
  - [Neural network and genetic algorithm based global path planning in a static environment - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.583.3340&rep=rep1&type=pdf)
  - [Traveling Salesman Problem using Genetic Algorithm - Blog](https://www.geeksforgeeks.org/traveling-salesman-problem-using-genetic-algorithm/)
  - [A KNOWLEDGE-BASED GENETIC ALGORITHM FOR PATH PLANNING OF MOBILE ROBOTS - Thesis](https://atrium.lib.uoguelph.ca/xmlui/bitstream/handle/10214/22039/Hu_Yanrong_MSc.pdf?sequence=2)
