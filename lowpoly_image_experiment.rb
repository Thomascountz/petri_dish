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
)

triangle = Triangle.new(
  x1: 5,
  y1: 14,
  x2: 49,
  y2: 31,
  x3: 55,
  y3: 10,
  grayscale: 160
)

IMAGE_HEIGHT_PX = 100
IMAGE_WIDTH_PX = 100

image = Magick::Image.new(IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX) { |options| options.background_color = "white" }
draw = Magick::Draw.new
draw.fill("rgb(#{triangle.grayscale}, #{triangle.grayscale}, #{triangle.grayscale})")
draw.polygon(triangle.x1, triangle.y1, triangle.x2, triangle.y2, triangle.x3, triangle.y3)

draw.draw(image)
image.write("output_2.png")

def import_image(path)
  image = Magick::Image.read(path).first

  crop_size = [image.columns, image.rows].min
  crop_x = (image.columns - crop_size) / 2
  crop_y = (image.rows - crop_size) / 2

  image
    .crop(crop_x, crop_y, crop_size, crop_size)
    .resize(100, 100)
    .quantize(256, Magick::GRAYColorspace)
    .write("input_convert.png")
end

import_image("astronaut.jpg")
