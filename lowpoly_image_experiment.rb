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


IMAGE_HEIGHT_PX = 100
IMAGE_WIDTH_PX = 100
GREYSCALE_VALUES = (0..255).to_a
POPULATION_SIZE = 5
MIN_MEMBER_SIZE = 10
MAX_MEMBER_SIZE = 75

def random_triangle
  Triangle.new(
    x1: rand(IMAGE_WIDTH_PX),
    y1: rand(IMAGE_HEIGHT_PX),
    x2: rand(IMAGE_WIDTH_PX),
    y2: rand(IMAGE_HEIGHT_PX),
    x3: rand(IMAGE_WIDTH_PX),
    y3: rand(IMAGE_HEIGHT_PX),
    grayscale: GREYSCALE_VALUES.sample
  )
end

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

seed_population
