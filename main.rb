require 'muni'
require_relative "lib/lcd/char16x2"

class Main

  def initialize(options = {})
    @location = options[:location] || "Sansome St & Sutter St"

    # Find specific or all routes.
    @routes = options[:routes] || Muni::Route.find(:all)

    default_index = @routes.index{|route| route.tag.to_s == "10"}

    @route ||= @routes.rotate!(default_index)[0]
    @isInbound ||= false

    @lcd = Adafruit::LCD::Char16x2.new{|lcd|
      lcd.clear
      lcd.backlight(Adafruit::LCD::Char16x2::WHITE)
      lcd.wrapMessage(predictions())
    }
  end

  def setupButtons
    loop do
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
    @route = @routes.rotate!(-1)[0]
    writeAndSchedulePredictions()
  end

  def down()
    @route = @routes.rotate!(1)[0]
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
      @lcd.wrapMessage("Inbound")
    else
      @lcd.wrapMessage("Outbound")
    end
    sleep 1 # to see the message
    writeAndSchedulePredictions()
  end

  def writeAndSchedulePredictions()
    @writePredictionsThread.kill if @writePredictionsThread && @writePredictionsThread.alive?
    @writePredictionsThread = Thread.new do
      loop do
        writePredictions()
        sleep 60
      end
    end
  end

  def writePredictions()
    @lcd.clear
    @lcd.wrapMessage("#{@route.title}:Loading...")
    str = predictions()
    @lcd.clear
    @lcd.wrapMessage(str)
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
    puts str
    str
  end
end

main = Main.new(
  location: "23rd St & Wisconsin St",
  routes: [
    OpenStruct.new(tag: 10), OpenStruct.new(tag: 48)
  ]
)
main.setupButtons
