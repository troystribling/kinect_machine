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
      if  msg['request']
        send_method(msg['type'].to_sym, msg['request'])
      else
        send_method(msg['type'].to_sym)
      end
    end
    def tilt(msg)
      Freenect.set_tilt(msg['tilt'].to_i)
    end
    def tilt_state
      freenect_tilt_state = Freenect.get_tilt_state
      msg = {
        :titl_angle  => Freenect.get_tilt(freenect_tilt_state),
        :tilt_status => Freenect.get_tilt_status(freenect_tilt_state),
        :acc         =>  Freenect.get_acceleration(freenect_tilt_state)
      }
      socket.send(msg.to_json)
    end
    def led(msg)
      Freenect.set_led(msg['led'].to_sym)
    end
  end
end
