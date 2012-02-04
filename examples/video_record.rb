require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine

  attr_reader :state, :file

  def post_init
    @file = File.open(ARGV.first, 'wb')
    puts "CONNECTED"
    @state = :connected
    EventMachine.next_tick{send_data({:action => :set_mode, :params => {:mode => :video}}.to_json)}
  end

  def receive_data(data)
    unless state.eql?(:running)
      msg = JSON.parse(data)
      if msg['status'].eql?('success')
        puts "RECEIVED MSG: #{msg.inspect}"
        if msg['action'].eql?('set_mode')
          send_data({:action => :start_video, :params => {:video_format => :freenect_video_rgb}}.to_json)
        elsif msg['action'].eql?('start_video')
          @state = :running
         else
        end
      else
        puts "ERROR: ACTION=#{msg['action']}, MESSAGE=#{msg['message']}"
        EventMachine.stop_event_loop
      end
    else
      p data.length
     file.puts data
    end
  end

  def unbind
    puts "CLOSED"
    file.close
    EventMachine.stop_event_loop
  end

end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end

