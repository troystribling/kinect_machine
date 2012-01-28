module KinectMachine

  @sessions = 0

  def self.websockets
    EventMachine::WebSocket.start(:host => host, :port => port) do |socket|
      socket.onopen do
        KinectMachine.sessions += 1
        logger.info "Websocket opened: #{socket.request.inspect}"
        logger.info "Sessions: #{self.sessions}"
      end
      socket.onclose do 
        self.sessions -= 1
        logger.info "Sessions: #{self.sessions}"
        logger.info "Websocket closed: #{socket.request.inspect}"
      end
      socket.onmessage do |msg|
       KinectMachine::Server.process_msg(socket, msg)
      end
    end
  end

  class Sockets < EventMachine::Connection
    def post_init
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      KinectMachine.sessions += 1
      KinectMachine.logger.info "Socket opened: #{ip}:#{port}"
      KinectMachine.logger.info "Sessions: #{KinectMachine.sessions}"
    end
    def receive_data(data)
     KinectMachine::Server.process_msg(self, data)
    end
    def send(msg)
      send_data(msg)
    end
    def unbind
      KinectMachine.sessions -= 1
      KinectMachine.logger.info "Socket closed"
      KinectMachine.logger.info "Sessions: #{KinectMachine.sessions}"
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
      logger.debug "DEBUG messages enabled"
      logger.debug "Config #{config.inspect}"
      logger.debug "Host: #{host}, Port: #{port}"
      logger.info "Found #{kinects} kinects"
      EventMachine.run do
        if use_websockets
          logger.info "Starting websocket server"
          websockets
        else
          logger.info "Starting socket server"
          sockets
        end
        logger.info "kinectMachine started on #{self.host}:#{self.port}"
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


