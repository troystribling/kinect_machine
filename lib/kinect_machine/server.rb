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
       logger.info "Sending message on socket: #{socket.request.inspect}"
       response =  "#{msg}"
       logger.info "Message: '#{response}'"
       socket.send response
    end
  end
end
