require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine
  @tilts = [0, -10, -20, 0, 10, 20 ,0]
  @tilt = 0
  class << self
    attr_accessor :tilts, :tilt
  end
  def post_init
    puts "connected"
    tilt_task
  end
  def receive_data(data)
    p data
  end
  def unbind
    puts "closed"
    EventMachine.stop_event_loop
  end
  def tilt_task
    EventMachine.add_timer(5) do
      tilt KinectMachine.tilts[KinectMachine.tilt]
      KinectMachine.tilt += 1
      if KinectMachine.tilt < KinectMachine.tilts.length
        tilt_state_task
      else
        EventMachine.stop_event_loop
      end
    end
  end
  def tilt_state_task
    EventMachine.add_timer(5) do
      tilt_state
      tilt_task
    end
  end
   def tilt(val)
    msg = {:type => :tilt, :request => {:tilt => val}}
    puts "Sending msg: #{msg.inspect}"
    send_data(msg.to_json)
  end
  def tilt_state
    msg = {:type => :tilt_state}
    puts "Sending msg: #{msg.inspect}"
    send_data(msg.to_json)
  end
end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end
