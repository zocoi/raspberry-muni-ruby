require 'muni'
require_relative "lib/lcd/char16x2"

class Main

  def initialize
    @location = "Sansome St & Sutter St"

    # Find all routes.
    @routes = Muni::Route.find(:all)
    # puts routes.inspect

    default_index = @routes.index{|route| route.tag =="10"}
    default_route = @routes[default_index]

    @index ||= default_index
    @route ||= default_route
    @isInbound ||= false

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
      when (buttons >> Adafruit::LCD::Char16x2::DOWN) & 1 > 0
        puts "DOWN pressed"
        down()
      end
      sleep 0.1
    end
  end

  def up()
    @index = @index - 1
    @route = @routes[index]
    writeAndSchedulePredictions()
  end

  def down()
    @index = @index + 1
    @route = @routes[index]
    writeAndSchedulePredictions()
  end

  def right()
    switchDirection()
  end

  def left()
    switchDirection()
  end

  def switchDirection()
    @isInbound = !@isInbound
    @lcd.clear
    if @isInbound
      @lcd.message("Inbound")
    else
      @lcd.message("Outbound")
    end
    writeAndSchedulePredictions()
  end

  def writeAndSchedulePredictions()
    @t.kill if @t
    @t = Thread.new do
      loop do
        writePredictions()
        sleep 60
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
    if @isInbound
      predictions = @route.inbound.stop_at(@location).predictions
    else
      predictions = @route.outbound.stop_at(@location).predictions
    end
    str = "#{@route.title}:" + predictions.map(&:minutes).join(",")
    str = str.scan(/.{1,16}/).join("\n")
    puts str
    str
  end
end

main = Main.new
