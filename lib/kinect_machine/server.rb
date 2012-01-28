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
      send_method(msg['type'].to_sym, msg['request']) if (msg['type'])
    end
    def tilt(msg)
      Freenect.set_tilt(msg['tilt'].to_i)
    end
    def led(msg)
      Freenect.set_led(msg['led'].to_sym)
    end
  end
end
