### Low-Poly Image Reconstruction

<p align="center">
  <img src="result.png" style="display: block; margin: 0 auto 10px auto;">
  <img src="montage.png" style="display: block; margin: 0 auto;">
</p>

The `low_poly_image_reconstruction.rb` script demonstrates a use of the Petri Dish library for generating a low-poly representation of an image. It gives us a glimpse of the potential applications of genetic algorithms in creative digital tasks.

In this script, each member of the population represents a unique rendering of an image. The genetic material, or "genes", for each member are a series of `Point`-s spread across the image, each with its own `x` and `y` coordinates and `grayscale` value. These `Point`-s serve as vertices for triangles, which are created using the Delaunay triangulation algorithm, a method for efficiently generating triangles from a given set of points. 

To initialize the image, evenly spaced vertices are selected (though small amount of randomness, or "jitter", is introduced to the point locations to prevent issues with the triangulation algorithm when points align). The `grayscale` value of each vertices is initialized as a random 8-bit number and the final fill value for the triangle is calculated by averaging the grayscale values of its three vertices.

The fitness of each member is then calculated by comparing its generated image with the target image. The closer the resemblance, the higher the fitness. Specifically, a fitness function based on the mean error per pixel is used: the lower the mean error (i.e., the closer the member's image to the target), the higher the fitness score. 

To create a "generation" of the population of images, parents are selected using the roulette wheel method, also known as stochastic acceptance. This method works by calculating a "wheel of fortune" where each member of the population gets a slice proportional to their fitness. Then, a random number is generated to select two members from the wheel. This method provides a balance, giving members with higher fitness a better chance of being selected, while still allowing less fit members a shot, helping to allow diversity in the population.

To further maintain diversity in the population, the script uses a high mutation rate of `0.1`. Given the relatively small population size of `50`, and an elitism rate of `0.1` (meaning that 5 highest fitness members are carried over to the next generation unmutated), a high mutation rate helps ensure that there is enough diversity in the gene pool to allow for continual exploration of the search space.

The script is designed to run for a fixed number of generations (2500 in this case), and during crossover, if a new high fitness score has been achieved, the corresponding image is saved to an output directory via the `highest_fitness_callback`. This way, we can track the progress of the algorithm and observe how the images evolve over time.

To set off on this journey yourself, update the `LOW_POLY_RECONSTRUCTION_PATH` and `INPUT_IMAGE_PATH` to point to the working directory and image you want to reconstruct, respectively. Then, run the following command in your terminal:

```bash
bundle exec ruby <PATH_TO_SCRIPT>/low_poly_image_reconstruction.rb
```

Remember, this script requires the RMagick and Delaunator libraries for image processing and triangulation. These will be installed automatically via an inline Gemfile. It reads an input image and saves the progressively evolved images to a specified output directory. 