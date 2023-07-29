### Traveling Salesperson

```
       ┌──────────────────────────────────────────────────┐ 
     5 │        ':..                                      │ 
       │         '. '.                                    │ 
       │           :  ''.                                 │ 
       │            '.   ''.                            .:│ 
       │             '.     '..                      .':' │ 
       │               :       '.                 ..' .'  │ 
       │              .''        '''''''''''''''''   :    │ 
   y   │           .''                             .'     │ 
       │        ..'                               .'      │ 
       │     ..'                                 :        │ 
       │   .'                                    :        │ 
       │.''                                      :        │ 
       │'''...                           ....'''''        │ 
       │      '''...             ....''''                 │ 
     0 │            ''.......''''                         │ 
       └──────────────────────────────────────────────────┘ 
       2                                                  8
                                x
```

The `salesperson_example.rb` is an example of using the Petri Dish library to solve a more complex problem: The Traveling Salesperson Problem. In this problem, a salesperson needs to visit a number of cities, each at a different location, and return to the starting city. The goal is to find the shortest possible route that visits each city exactly once.

In this example, each city is represented as a `Gene` object with `x` and `y` coordinates. The genetic material is the array of all possible `x` and `y` coordinates. The fitness function is defined as the inverse of the total distance of the route, which means that shorter routes will have higher fitness.

The parents for crossover are selected using a tournament selection function which picks the best 2 out of a random sample of 20% of the population. Crossover is performed using an ordered crossover method which maintains the relative order of the genes from both parents.

Mutation is implemented as a chance to swap two genes in a member. The mutation rate is set to 0.01, which means that on average, 1% of the genes in a member will mutate in each generation.

The evolutionary process runs for a fixed number of generations, and the highest fitness member in each generation is saved to a CSV file.

To run the example, simply execute the following command in your terminal:

```bash
bundle exec ruby examples/salesperson_example.rb
```
