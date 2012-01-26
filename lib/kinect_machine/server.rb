module KinectMachine
  class Server
    @sessions = 0
    class << self
      attr_reader :sessions
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
      p msg
    end
    def led(msg)
    end
  end
end
