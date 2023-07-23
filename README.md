# Petri Dish: A Genetic Algorithm Library for Ruby

## Introduction

Welcome to Petri Dish! This project is a Ruby-based library designed to provide functionality for genetic algorithms. PetriDish uses concepts from genetics and natural selection to solve optimization problems. This library is designed to be flexible and configurable, allowing you to create and customize your own genetic algorithms.

## Overview of Genetic Algorithms

Genetic algorithms are a type of optimization algorithm inspired by the process of natural selection. They use techniques based on genetics and evolution, such as mutation, crossover (recombination), and selection, to generate high-quality solutions for optimization and search problems. 

The fundamental steps in a genetic algorithm include:

1. **Population Creation**: Generate an initial population of individuals with random genetic code (DNA).
2. **Fitness Evaluation**: Assign a fitness score to each individual in the population based on a fitness function.
3. **Selection**: Create a mating pool by selecting individuals for reproduction. More fit individuals are more likely to be selected.
4. **Crossover**: Generate new individuals (offspring) by combining the DNA of two parents.
5. **Mutation**: Introduce small random changes in the offspring's genetic code to maintain diversity in the population.
6. **Generational Loop**: Repeat the process of selection, crossover, and mutation over many generations. The algorithm typically terminates when a satisfactory fitness level has been reached for the population.

## Key Concepts of This Library

PetriDish consists of several key classes that encapsulate the various components of a genetic algorithm:

- **World**: This is the main engine that drives the genetic algorithm, including maintaining the current population, running the generations, and checking for termination conditions.
- **Population**: A collection of individuals or _members_ that make up a generation.
- **Member**: An individual in the population. Members have genes that are assessed for fitness. The algorithm optimizes to find the member with the fittest genes.
- **Metadata**: Contains information about the current state of the algorithm, such as the highest fitness achieved so far and the current generation count.
- **Configuration**: This class allows you to customize various aspects of the genetic algorithm, such as the population size, mutation rate, genetic material, fitness function, and many others. Default values are provided but can be overridden to suit your specific use case.

## Configuration 

You can modify various aspects of the genetic algorithm by changing the configuration settings in the `Configuration` class. Here are some of the key settings:

- **population_size**: The number of members in each generation.
- **mutation_rate**: The probability of a mutation occurring in a member's genes.
- **genetic_material**: The set of possible values a gene can take.
- **target_genes**: The ideal set of genes that the algorithm aims to evolve towards (can be used in some optimization problems).
- **max_generations**: The maximum number of generations to run the algorithm for.
- **gene_instantiation_function**: A function to generate a new set of genes for a member.
- **fitness_function**: A function to evaluate the fitness of a member.
- **parents_selection_function**: A function to select a parent for reproduction.
- **crossover_function**: A function to combine the genes of two parents to produce offspring.
- **mutation_function**: A function to introduce random changes in a member's genes.
- **end_condition_function**: A function to determine when the algorithm should terminate.

Here's an example of how to customize these settings:

```ruby
require_relative "./petridish"

PetriDish::World.configure do |config|
  config.max_generations = 1000
  config.population_size = 100
  config.mutation_rate = 0.01
  config.genetic_material = (0..9).to_a
  config.target_genes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
  config.gene_instantiation_function = -> { config.target_genes.shuffle }
  config.fitness_function = ->(member) { (member.genes.sum - config.target_genes.sum).abs }
  config.parents_selection_function = PetriDish::Configuration.elitist_fitness_parents_selection_function
  config.crossover_function = PetriDish::Configuration.random_midpoint_crossover_function
  config.mutation_function = PetriDish::Configuration.random_mutation_function
  config.end_condition_function = ->(member) { member.genes == config.target_genes }
end

PetriDish::World.run
```

This configuration sets up a genetic algorithm that aims to evolve a member whose genes are a shuffled version of the target genes. The algorithm will run for a maximum of 1000 generations, with each generation consisting of 100 members. The mutation rate is set to 1%, meaning each gene has a 1% chance of being randomly changed during mutation. The fitness function is defined as the absolute difference between the sum of a member's genes and the sum of the target genes. The algorithm will select the fittest member for reproduction (elitist selection), use a random point for crossover, and terminate the algorithm when a member's genes match the target genes.

Please note that the provided configuration is merely an example. You are encouraged to experiment with different settings and functions to suit your specific problem and requirements.

Also, for advanced usage, you can create custom classes for genes and introduce complex fitness functions, mutation functions, and crossover functions. Please refer to the provided advanced example for a use-case involving the Traveling Salesman Problem.

## Resources

For a deeper understanding of genetic algorithms and their application, we recommend the following resources:

- [Genetic Algorithms Explained By Example - Youtube](https://www.youtube.com/watch?v=uQj5UNhCPuo)
- [Genetic Algorithms for Autonomous Robot Navigation - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.208.9941&rep=rep1&type=pdf)
- [Nature of Code, Chapter 9 - The Evolution of Code - Book](https://natureofcode.com/book/chapter-9-the-evolution-of-code/)
- [Weighted Random Sampling in Ruby - Gist](https://gist.github.com/O-I/3e0654509dd8057b539a)
- [Tail Call Optimization in Ruby - Blog](https://nithinbekal.com/posts/ruby-tco/)
- [Neural network and genetic algorithm based global path planning in a static environment - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.583.3340&rep=rep1&type=pdf)
- [Traveling Salesman Problem using Genetic Algorithm - Blog](https://www.geeksforgeeks.org/traveling-salesman-problem-using-genetic-algorithm/)
- [A KNOWLEDGE-BASED GENETIC ALGORITHM FOR PATH PLANNING OF MOBILE ROBOTS - Thesis](https://atrium.lib.uoguelph.ca/xmlui/bitstream/handle/10214/22039/Hu_Yanrong_MSc.pdf?sequence=2)
