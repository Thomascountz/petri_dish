require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rmagick", require: "rmagick"
end

IMAGE_HEIGHT_PX = 100
IMAGE_WIDTH_PX = 100

image = Magick::Image.new(IMAGE_WIDTH_PX, IMAGE_HEIGHT_PX) { |options| options.background_color = "white" }
draw = Magick::Draw.new
draw.stroke("black")
draw.line(0, 0, 100, 100)
draw.draw(image)
image.write("output_1.png")
