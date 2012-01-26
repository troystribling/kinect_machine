require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine

  def post_init
    puts "connected"
    tilt(5)
  end

  def tilt(val)
    msg = {:type => :tilt, :request => {:tilt => 5}}
    send_data msg.to_json
  end

  def receive_data(data)
    p data
  end

  def unbind
    puts "closed"
  end
end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end
