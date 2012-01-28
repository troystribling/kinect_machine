require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine
  @leds = [:led_off, :led_green, :led_red, :led_yellow, :led_blink_green, :led_blink_red_yellow, :led_off]
  @led = 0
  class << self
    attr_accessor :tilts, :tilt, :leds, :led
  end
  def post_init
    puts "connected"
    led_task
  end
  def receive_data(data)
    p data
  end
  def unbind
    puts "closed"
  end
  def led_task
    EventMachine.add_timer(5) do
      led KinectMachine.leds[KinectMachine.led]
      KinectMachine.led += 1
      if KinectMachine.led < KinectMachine.leds.length
        led_task
      end
    end
  end
  def led(val)
    msg = {:type => :led, :request => {:led => val}}
    puts "Sending msg: #{msg.inspect}"
    send_data msg.to_json
  end
end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end

