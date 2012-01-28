module KinectMachine
  class Server

   class << self
      def process_msg(socket, msg)
        server = self.new(socket)
        server.process_msg(msg)
      end
    end

    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    def logger; KinectMachine.logger; end

    def process_msg(msg)
      logger.info "Resceived message on socket: #{socket.inspect}"
      msg = JSON.parse(msg)
      logger.info "Message: '#{msg.inspect}'"
      if  msg['params']
        send_method(msg['action'].to_sym, msg['params'])
      else
        send_method(msg['action'].to_sym)
      end
    end

    def set_tilt(msg)
      Freenect.set_tilt(msg['tilt'].to_i)
      get_tilt_state
    end

    def get_tilt_state
      freenect_tilt_state = Freenect.get_tilt_state
      msg = {
        :action => :get_tilt_state,
        :data => {
          :titl_angle  => Freenect.get_tilt(freenect_tilt_state),
          :tilt_status => Freenect.get_tilt_status(freenect_tilt_state),
          :acc         => Freenect.get_acceleration(freenect_tilt_state)
      }}
      socket.send(msg.to_json)
    end

    def set_led(msg)
      led = msg['led'].to_sym
      Freenect.set_led(led)
      msg = {
        :action => :set_led,
        :data => {:led => led},
      }
      socket.send(msg.to_json)
    end

    def get_video_mode_count
      msg = {}
    end

    def get_depth_mode_count
      msg = {}
    end

   end
end
