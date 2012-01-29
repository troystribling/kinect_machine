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
    puts "CONNECTED"
    tilt_task
  end

  def receive_data(data)
    msg = JSON.parse(data)
    if msg['status'].eql?('success')
      puts "RECEIVED: #{msg.inspect}"
    else
      puts "ERROR: ACTION=#{msg['action']}, MESSAGE=#{msg['message']}"
      EventMachine.stop_event_loop
    end
  end

  def unbind
    puts "CLOSED"
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
    msg = {:action=> :set_tilt, :params => {:tilt => val}}
    puts "SENDING: #{msg.inspect}"
    send_data(msg.to_json)
  end

  def tilt_state
    msg = {:action => :get_tilt_state}
    puts "SENDING: #{msg.inspect}"
    send_data(msg.to_json)
  end

end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end
