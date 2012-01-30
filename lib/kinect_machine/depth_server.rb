module KinectMachine
  module DepthServer

    def start_depth(data)
      @depth_running = true
      if format = data['depth_format']
      end
    end

    def stop_depth
      @depth_running = false
    end

    def run_depth(format)
      if depth_running
      end
    end

  end
end

