require 'rubygems'
require 'eventmachine'

module KinectMachine

  def post_init
    puts "connected"
    send_data "testing"
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
