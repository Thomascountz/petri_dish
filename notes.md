# Genetic Algorithm

1. Create a population
  - Create a population of `N` elements, each with randomly generated DNA.
  - Variation: the amount of distinct/unique attributes values amongst a population
  - DNA or Genes: the set of properties that get past through from parents to children
    - Genotype: data/values
      - e.g. `152`
    - Phenotype: expression of that data
      - e.g. a certain shade of gray or a length of a line
2. Selection
  - Evaluate fitness
    - Fitness function: a numerical score given to each member of the population
      - e.g. number of correct characters in the correct position for a given string of text compared to a target string of text
      - e.g. number of correct pixels in the correct position and of the correct color for given polygon compared to an image
  - Create a mating pool: a group of members fit to become parents
    - Elitist method: choose the members with the highest fitness
      - e.g. the top two members or the top 50% 
      - Inhibits variation
    - Probabilistic method: normalize the fitness scores and express each as a percentage probability of being selected
      - It guarantees that more-fit parents are more likely to be selected
      - Maintains variation by given a chance for the least fit members to pass on their DNA
        - This is important because the lowest scoring member might be the only member with the correct genetic data 
3. Reproduction
  - Generate `N` new members to form the next generation of the population
  - Heredity: children inherit traits from their parents
  - Asexual reproduction: choose one parent and clone it exactly
  - Crossover: creating a child member from the genetic code of two parents
    - 50/50 midpoint method: take exactly half of the genetic material from each parent and combine it to make a child
    - Random midpoint method: randomly split data from each parent's genetic material to make a child
    - Random sampling method: for each piece of genetic data, copy from either parent randomly
      - If the ordering of genetic information plays a role in expressing the phenotype, this may not work
    - You can reproduce with more or less than two parents
  - Mutation: Introduce a random change to the child's genetic code after crossover
    - e.g. changing a character in a string by one step up or down the alphabet
    - e.g. replacing a character in a string with a random character
    - Rate: The probability of randomness being introduced to each piece of genetic data via mutation 
      - High mutation rates can negate heredity


- Resources
  - [Genetic Algorithms Explained By Example - Youtube](https://www.youtube.com/watch?v=uQj5UNhCPuo)
  - [Genetic Algorithms for Autonomous Robot Navigation - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.208.9941&rep=rep1&type=pdf)
  - [Nature of Code, Chapter 9 - The Evolution of Code - Book](https://natureofcode.com/book/chapter-9-the-evolution-of-code/)
  - [Weighted Random Sampling in Ruby - Gist](https://gist.github.com/O-I/3e0654509dd8057b539a)
  - [Tail Call Optimization in Ruby - Blog](https://nithinbekal.com/posts/ruby-tco/)
  - [Neural network and genetic algorithm based global path planning in a static environment - Paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.583.3340&rep=rep1&type=pdf)
  - [Traveling Salesman Problem using Genetic Algorithm - Blog](https://www.geeksforgeeks.org/traveling-salesman-problem-using-genetic-algorithm/)
  - [A KNOWLEDGE-BASED GENETIC ALGORITHM FOR PATH PLANNING OF MOBILE ROBOTS - Thesis](https://atrium.lib.uoguelph.ca/xmlui/bitstream/handle/10214/22039/Hu_Yanrong_MSc.pdf?sequence=2)