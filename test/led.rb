require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine

  @leds = [:led_off, :led_green, :led_red, :led_yellow, :led_blink_green, :led_blink_red_yellow, :led_off]
  @led = 0

  class << self
    attr_accessor :leds, :led
  end

  def post_init
    puts "CONNECTED"
    EventMachine.next_tick{send_data({:action => :set_mode, :params => {:mode => :command}}.to_json)}
  end

  def receive_data(data)
    msg = JSON.parse(data)
    if msg['status'].eql?('success')
      puts "RECEIVED: #{msg.inspect}"
      led_task if msg['action'].eql?('set_mode')
     else
      puts "ERROR: ACTION=#{msg['action']}, MESSAGE=#{msg['message']}"
      EventMachine.stop_event_loop
    end
  end

  def unbind
    puts "CLOSED"
    EventMachine.stop_event_loop
  end

  def led_task
    EventMachine.add_timer(5) do
      led KinectMachine.leds[KinectMachine.led]
      KinectMachine.led += 1
      if KinectMachine.led < KinectMachine.leds.length
        led_task
      else
        EventMachine.stop_event_loop
      end
    end
  end

  def led(val)
    msg = {:action => :set_led, :params => {:led => val}}
    puts "SENDING: #{msg.inspect}"
    send_data(msg.to_json)
  end

end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end

