require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine

  class << self
    attr_accessor :state
  end

  def post_init
    puts "CONNECTED"
    EventMachine.next_tick{send_data({:action => :set_mode, :params => {:mode => :video}}.to_json)}
  end

  def receive_data(data)
    msg = JSON.parse(data)
    if msg['status'].eql?('success')
      puts "RECEIVED MSG: #{msg.inspect}"
      if msg['action'].eql?('set_mode')
        state = :connected
        send_data({:action => :start_video, :params => {:video_format => :freenect_video_rgb}}.to_json)
      elsif msg['action'].eql?('start_video')
        state = :running
       else
      end
   else
      puts "ERROR: ACTION=#{msg['action']}, MESSAGE=#{msg['message']}"
      EventMachine.stop_event_loop
    end
  end

  def unbind
    puts "CLOSED"
    EventMachine.stop_event_loop
  end

end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end

