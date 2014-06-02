require 'muni'
require_relative "lib/lcd/char16x2"

class Main
  attr_accessor :location, :routes, :route, :index

  def initialize
    @location = "Sansome St & Sutter St"

    # Find all routes.
    @routes = Muni::Route.find(:all)
    # puts routes.inspect

    default_index = @routes.index{|route| route.tag =="10"}
    default_route = @routes[default_index]

    @index ||= default_index
    @route ||= default_route

    @lcd = Adafruit::LCD::Char16x2.new{|lcd|
      lcd.clear
      lcd.backlight(Adafruit::LCD::Char16x2::WHITE)
      lcd.message(predictions())
    }

    while true
      buttons = @lcd.buttons
      case
      when (buttons >> Adafruit::LCD::Char16x2::SELECT) & 1 > 0
        puts "SELECT pressed"
      when (buttons >> Adafruit::LCD::Char16x2::LEFT) & 1 > 0
        puts "LEFT pressed"
        left()
      when (buttons >> Adafruit::LCD::Char16x2::RIGHT) & 1 > 0
        puts "RIGHT pressed"
        right()
      when (buttons >> Adafruit::LCD::Char16x2::UP) & 1 > 0
        puts "UP pressed"
        up()
        preparePredictions()
      when (buttons >> Adafruit::LCD::Char16x2::DOWN) & 1 > 0
        puts "DOWN pressed"
        down()
        preparePredictions()
      end
      sleep 0.1
    end
  end

  def up()
    @index = @index - 1
    @route = @routes[index]
  end

  def down()
    @index = @index + 1
    @route = @routes[index]
  end

  # RED                     = 0x01
  # GREEN                   = 0x02
  # BLUE                    = 0x04
  # YELLOW                  = RED + GREEN
  # TEAL                    = GREEN + BLUE
  # VIOLET                  = RED + BLUE
  # WHITE                   = RED + GREEN + BLUE

  def right()
    lcd.backlight(Adafruit::LCD::Char16x2::WHITE)
  end

  def left()
    lcd.backlight(Adafruit::LCD::Char16x2::TEAL)
  end

  def preparePredictions()
    if @t
      @t.kill
    @t = Thread.new do
       loop do
         writePredictions()
         sleep 2000
       end
     end
  end

  def writePredictions()
    @lcd.clear
    @lcd.message("Loading...")
    str = predictions()
    @lcd.clear
    @lcd.message(str)
  end

  # Get a prediction
  def predictions()
    @route = Muni::Route.find(@route.tag)
    predictions = @route.outbound.stop_at(@location).predictions
    str = "#{@route.title}:" + predictions.map(&:minutes).join(",")
    str = str.scan(/.{1,16}/).join("\n")
    puts str
    str
  end
end

main = Main.new
