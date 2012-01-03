OptionParser.new do |opts|
  opts.banner = 'Usage: kinect_machine [options]'
  opts.separator ''
  opts.on('-c', '--config_path path', 'absolute path to configuration filr') {|a| KinectMachine.config_path = a}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| KinectMachine.log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

module KinectMachine
end
