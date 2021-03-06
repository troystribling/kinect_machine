$:.unshift(File.dirname(__FILE__))
require 'logger'
require 'optparse'
require 'socket'
require 'json'

class Object
  alias :send_method :send
end

require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'freenect'

require 'kinect_machine/server'
require 'kinect_machine/command_server'
require 'kinect_machine/depth_server'
require 'kinect_machine/video_server'
require 'kinect_machine/main'
