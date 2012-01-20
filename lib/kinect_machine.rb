$:.unshift(File.dirname(__FILE__))
require 'logger'
require 'optparse'
require 'socket'

require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'kinect_machine/server'
require 'kinect_machine/main'
