require 'muni'
require_relative "lib/lcd/char16x2"

class Main
  attr_accessor :location, :routes, :route, :index
  
  def initialize
    @location = "18th St & Connecticut St"

    # Find all routes.
    @routes = Muni::Route.find(:all)
    # puts routes.inspect

    default_index = @routes.index{|route| route.tag =="22"}
    default_route = @routes[default_index]

    @index ||= default_index
    @route ||= default_route

  end

  # Get a prediction
  def predictions()
    @route = Muni::Route.find(@route.tag)
    predictions = @route.inbound.stop_at(@location).predictions
    puts "#{@route.title}: " + predictions.map(&:minutes).join(", ")
  end

  def up()
    @index = @index - 1
    @route = @routes[index]
    predictions()
  end

  def down()
    @index = @index + 1
    @route = @routes[index]
    predictions()
  end
end

#
# if __FILE__ == $0
#
#   Adafruit::LCD::Char16x2.new{|lcd|
#     lcd.clear
#     lcd.backlight(Adafruit::LCD::Char16x2::WHITE)
#     lcd.message("life is like\nriding a bicycle")
#
#     while true
#       buttons = lcd.buttons
#       case
#       when (buttons >> Adafruit::LCD::Char16x2::SELECT) & 1 > 0
#         puts "SELECT pressed"
#       when (buttons >> Adafruit::LCD::Char16x2::LEFT) & 1 > 0
#         puts "LEFT pressed"
#       when (buttons >> Adafruit::LCD::Char16x2::RIGHT) & 1 > 0
#         puts "RIGHT pressed"
#       when (buttons >> Adafruit::LCD::Char16x2::UP) & 1 > 0
#         puts "UP pressed"
#       when (buttons >> Adafruit::LCD::Char16x2::DOWN) & 1 > 0
#         puts "DOWN pressed"
#       end
#       sleep 0.1
#     end
#   }
#
# end
