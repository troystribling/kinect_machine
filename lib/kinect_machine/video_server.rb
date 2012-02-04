module KinectMachine
  module VideoServer

    def self.extended(base)
      base.instance_eval do
        alias :close_target :close
        alias :close :close_video
      end
    end

    attr_reader :video_running, :frame_count

    def start_video(data)
      if format = data['video_format']
        @video_running = true
        @frame_count = 0
        video_mode = Freenect.find_video_mode(format.to_sym)
        send({
          :action => :start_video,
          :data   => {:format => format}
        })
        run_video(video_mode)
      else
        raise "'video_format' PARAM MISSING"
      end
    end

    def run_video(video_mode)
      if video_running
        EventMachine.next_tick do
          send_frame(Freenect.get_video(video_mode))
          run_video(video_mode)
        end
      end
    end

    def close_video
      @video_running = false
      close_target
    end

    def send_frame(frame)
      @frame_count += 1
      p frame.size
      logger.info "SENDING FRAME: #{frame_count}"
      socket.send(frame)
    end

  end
end

