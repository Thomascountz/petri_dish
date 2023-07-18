require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rmagick", require: "rmagick"
end

Triangle = Data.define(
  :x1,
  :y1,
  :x2,
  :y2,
  :x3,
  :y3,
  :grayscale
) do
  def vertices
    [
      [x1, y1],
      [x2, y2],
      [x3, y3]
    ]
  end
end


IMAGE_HEIGHT_PX = 500
IMAGE_WIDTH_PX = 500
GREYSCALE_VALUES = (0..255).to_a
POPULATION_SIZE = 5
MIN_MEMBER_SIZE = 150
MAX_MEMBER_SIZE = 300
MIN_RADIUS = 20
MAX_RADIUS = 80

def random_triangle
  # Choose a random point within the image
  center_x, center_y = rand(IMAGE_WIDTH_PX), rand(IMAGE_HEIGHT_PX)
  
  # Create a circle around the point with a random radius
  radius = rand(MIN_RADIUS..MAX_RADIUS)

  # Choose three random points on the circle's circumference. `rand * 2 *
  # Math::PI1 gives a random angle in the range `0` to `2 * Math::PI` radians,
  # i.e., anywhere around the full circumference of the circle.  Then, given the
  # angle and the radius, we can find the coordinates `(x, y)` on the circle by
  # using the formulas `x = center_x + radius * Math.cos(angle)` and `y =
  # center_y + radius * Math.sin(angle)`. These are basically the conversion
  # formulas from polar to Cartesian coordinates.
  angles = 3.times.map { rand * 2 * Math::PI }

  points = angles.map do |angle|
    x = center_x + radius * Math.cos(angle)
    y = center_y + radius * Math.sin(angle)
    [x, y]
  end

  Triangle.new(
    x1: points[0][0], y1: points[0][1],
    x2: points[1][0], y2: points[1][1],
    x3: points[2][0], y3: points[2][1],
    grayscale: GREYSCALE_VALUES.sample
  )
end

# This implementation produced triangles that inherently avoided the border
# and provided no controls of the size of the triangles
# def random_triangle
#   Triangle.new(
#     x1: rand(IMAGE_WIDTH_PX),
#     y1: rand(IMAGE_HEIGHT_PX),
#     x2: rand(IMAGE_WIDTH_PX),
#     y2: rand(IMAGE_HEIGHT_PX),
#     x3: rand(IMAGE_WIDTH_PX),
#     y3: rand(IMAGE_HEIGHT_PX),
#     grayscale: GREYSCALE_VALUES.sample
#   )
# end

def random_member
  Array.new(rand(MIN_MEMBER_SIZE..MAX_MEMBER_SIZE)) { random_triangle }
end

def random_population
  Array.new(POPULATION_SIZE) { random_member }
end

def seed_population
  random_population.each_with_index do |member, i|
    image = Magick::Image.new(IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX) { |options| options.background_color = "white" }
    draw = Magick::Draw.new
    member.each do |triangle|
      draw.fill("rgb(#{triangle.grayscale}, #{triangle.grayscale}, #{triangle.grayscale})")
      draw.polygon(*triangle.vertices.flatten)
    end

    draw.draw(image)
    image.write("population_#{i}.png")
  end
end

def import_image(path)
  image = Magick::Image.read(path).first

  crop_size = [image.columns, image.rows].min
  crop_x = (image.columns - crop_size) / 2
  crop_y = (image.rows - crop_size) / 2

  image
    .crop(crop_x, crop_y, crop_size, crop_size)
    .resize(IMAGE_HEIGHT_PX, IMAGE_WIDTH_PX)
    .quantize(256, Magick::GRAYColorspace)
    .write("input_convert.png")
end

# import_image("astronaut.jpg")
seed_population
