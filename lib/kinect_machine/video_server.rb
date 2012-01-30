module KinectMachine
  module VideoServer

    def start_video(data)
      @video_running = true
      if format = data['video_format']
        video_mode = Freenect.find_video_mode(format)
        run_video(video_mode)
      end
    end

    def stop_video
      @video_running = false
    end

    def run_video(video_mode)
      if video_running
        EventMachine.next_tick do
          video_buffer = Freenect.get_video(video_mode)
        end
      end
    end

  end
end

