## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [0.2.0]
### Added
- [Documentation] - Each example now has a README file with a description of the problem and the solution

### Changed
- [Configuration] - All `_callback` methods in `Configuration` can now be `nil` (i.e., optional)
- [Configuration] - Renamed `Configuration#next_generation_callback` to `Configuration#generation_start_callback`

### Removed
- [Configuration] - Removed `Configuration#target_genes`
- [API] - `Member#fitness_function` method is not exposed publicly anymore

## [0.1.1] - 2023-07-26

### Added

- Added `Configuration` class for customizing the parameters of the evolutionary algorithm.
- Added `Member` class to represent an individual in the population.
- Added `Metadata` class to keep track of the evolution process.
- Added `World` class to run the evolutionary algorithm.
- Initial implementation of evolutionary algorithm operations, including selection, crossover, and mutation.
- Added fitness function support for evaluating the quality of individuals in the population.
- Added callback functions for various events in the evolution process, including when a new highest fitness is found, when the maximum number of generations is reached, and when the end condition is met.
- Included an example of using the library to solve a simple genetic algorithm problem (lazy dog example).
- Included an example of using the library to solve the Traveling Salesperson Problem (salesperson example).
