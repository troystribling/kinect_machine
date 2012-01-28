require 'rubygems'
require 'json'
require 'eventmachine'

module KinectMachine
  @video_modes = 0
  @video_mode = 0
  @depth_modes = 0
  @depth_mode = 0
  @video_formats = [:freenect_video_rgb, :freenect_video_bayer, :freenect_video_ir_8bit, :freenect_video_ir_10bit, 
                    :freenect_video_ir_10bit_packed, :freenect_video_yuv_rgb, :freenect_video_yuv_raw]
  @video_format = 0
  @depth_formats = [:freenect_depth_11bit, :freenect_depth_10bit, :freenect_depth_11bit_packed, :freenect_depth_10bit_packed]
  @depth_format = 0

  class << self
    attr_accessor :video_modes, :video_mode, :depth_modes, :depth_mode, :video_formats, :video_format, :depth_formats, :depth_format
  end

  def post_init
    puts "CONNECTED"
    EventMachine.next_tick do
      send_data({:action => :get_video_mode_count}.to_json)
    end
 end

  def receive_data(data)
    msg = JSON.parse(data)
    send(msg['action'].to_sym, msg['data'])
  end

  def unbind
    puts "CLOSED"
    EventMachine.stop_event_loop
  end

  def get_video_mode_count(data)
    puts "VIDEO MODE COUNT: #{data['video_mode_count']}"
    send_data({:action => :get_depth_mode_count}.to_json)
  end

  def get_depth_mode_count(data)
    puts "DEPTH MODE COUNT: #{data['depth_mode_count']}"
    EventMachine.stop_event_loop
  end

end

EventMachine::run do
  EventMachine::connect '10.0.1.253', 8008, KinectMachine
end

