OptionParser.new do |opts|
  opts.banner = 'Usage: kinect_machine [options]'
  opts.separator ''
  opts.on('-c', '--config_file path', 'absolute path to configuration file') {|c| KinectMachine.config_file = c}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| KinectMachine.log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

module KinectMachine
  class KinectMachineError < Exception; end
  @app_path = File.expand_path(File.dirname($0))
  @config_file = File.join(self.app_path, "kinect_machine.yml")
  @log_file = STDOUT
  class << self
    attr_accessor :config_file, :config, :app_path, :log_file
    def logger; @logger ||= Logger.new(STDOUT); end
    def logger=(logger); @logger = logger; end
    def add_path(dir); File.join(self.app_path, dir); end
    def boot
      self.log_file = add_path(self.log_file)
      self.logger = Logger.new(self.log_file, 10, 1024000)
      self.logger.level = Logger::WARN 
      if File.exists?(self.config_file)
        self.config = File.open(self.config_file) {|yf| YAML::load(yf)}
      else
      end
    end
  end
end

at_exit do
  KinectMachine.boot
end


