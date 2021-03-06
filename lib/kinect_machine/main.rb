module KinectMachine

  @sessions = 0
  MAX_SESSIONS = 1

  def self.websockets
    EventMachine::WebSocket.start(:host => host, :port => port) do |socket|
      server = Server.new(socket)
      socket.onopen do
        KinectMachine.sessions += 1
        logger.info "WEBSOCKET OPENED: #{socket.request.inspect}"
        logger.info "SESSIONS: #{self.sessions}"
      end
      socket.onclose do 
        self.sessions -= 1
        server.close
        logger.info "SESSIONS: #{self.sessions}"
        logger.info "WEBSOCKET CLOSED: #{socket.request.inspect}"
      end
      socket.onmessage do |data|
        server.process_msg(data)
      end
    end
  end

  class Sockets < EventMachine::Connection

    attr_reader :server

    def post_init
      @server = Server.new(self)
      KinectMachine.sessions += 1
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      KinectMachine.logger.info "SOCKET OPENED: #{ip}:#{port}"
      KinectMachine.logger.info "SESSIONS: #{KinectMachine.sessions}"
    end

    def receive_data(data)
     server.process_msg(data)
    end

    def send(msg)
      send_data(msg)
    end

    def unbind
      KinectMachine.sessions -= 1
      server.close
      KinectMachine.logger.info "SOCKET CLOSED"
      KinectMachine.logger.info "SESSIONS: #{KinectMachine.sessions}"
    end

  end

  def self.sockets
    EventMachine.start_server host, port, Sockets
  end

  class KinectMachineError < Exception; end

  class << self

    attr_reader :kinects
    attr_accessor :config_file, :config, :app_path, :log_file, :debug, :use_websockets, :sessions

    def logger; @logger ||= Logger.new(STDOUT); end
    def logger=(logger); @logger = logger; end
    def add_path(dir); File.join(self.app_path, dir); end
    def host; config['host'] || '0.0.0.0'; end
    def port; config['port'] || '8008'; end

    def boot
      @app_path = File.expand_path(File.dirname($0))
      @config_file = File.join(self.app_path, "kinect_machine.yml")
      @log_file ||= STDOUT
      @kinects = Freenect.get_device_count
      self.logger = Logger.new(self.log_file, 10, 1024000)
      self.logger.level = self.debug ? Logger::DEBUG : Logger::INFO
      self.config = File.exists?(self.config_file) ? File.open(self.config_file){|yf| YAML::load(yf)} : {}
      logger.debug "DEBUG MESSAGES ENABLED"
      logger.debug "CONFIG: #{config.inspect}"
      logger.debug "HOST: #{host}, PORT: #{port}"
      logger.info "FOUND #{kinects} KINECTS"
      if kinects == 1
        EventMachine.run do
          if use_websockets
            logger.info "STARTING WEBSOCKET SERVER"
            websockets
          else
            logger.info "STARTING SOCKET SERVER"
            sockets
          end
          logger.info "kinectMachine STARTED ON: #{self.host}:#{self.port}"
        end
      else
        logger.error "NO KINECTS FOUND"
      end
    end

  end
end

OptionParser.new do |opts|
  opts.banner = 'Usage: kinect_machine [options]'
  opts.separator ''
  opts.on('-c', '--config_file path', 'absolute path to configuration file') {|c| KinectMachine.config_file = c}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| KinectMachine.log_file = f}
  opts.on('-d', '--debug', 'write debug messages') {|d| KinectMachine.debug = d}
  opts.on('-w', '--websockets', 'use websockets') {|w| KinectMachine.use_websockets = w}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

at_exit do
  KinectMachine.boot
end


