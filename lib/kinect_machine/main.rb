module KinectMachine
  class KinectMachineError < Exception; end
  class << self
    attr_accessor :config_file, :config, :app_path, :log_file, :debug
    def logger; @logger ||= Logger.new(STDOUT); end
    def logger=(logger); @logger = logger; end
    def add_path(dir); File.join(self.app_path, dir); end
    def host; config['host'] || '0.0.0.0'; end
    def port; config['port'] || '8008'; end
    def boot
      @app_path = File.expand_path(File.dirname($0))
      @config_file = File.join(self.app_path, "kinect_machine.yml")
      @log_file ||= STDOUT
      self.logger = Logger.new(self.log_file, 10, 1024000)
      self.logger.level = self.debug ? Logger::DEBUG : Logger::INFO
      self.config = File.exists?(self.config_file) ? File.open(self.config_file){|yf| YAML::load(yf)} : {}
      logger.debug "DEBUG messages enabled"
      logger.debug "Config #{config.inspect}"
      logger.debug "Host: #{host}, Port: #{port}"
      EventMachine::run do
        EventMachine::WebSocket.start(:host => host, :port => port) do |socket|
          socket.onopen do
            logger.info "Socket opened: #{socket.request.inspect}"
            socket.send "Hello Client"
          end
          socket.onclose do 
            logger.info "Socket closed: #{socket.request.inspect}"
          end
          socket.onmessage {|msg|
            logger.info "Received message on socket: #{socket.request.inspect}"
            logger.info "Message: #{msg}"
            KinectMachine::Server.process_msg(socket, msg)
          }
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
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

at_exit do
  KinectMachine.boot
end


