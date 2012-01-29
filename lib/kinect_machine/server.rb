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
      logger.info "RECEIVED MESSAGE ON SOCKET: #{socket.inspect}"
      msg = JSON.parse(msg)
      action, params = msg['action'].to_sym, msg['params']
      logger.info "ACTION: '#{action}'"
      logger.info "PARAMS: '#{params.inspect}'"
      if respond_to?(action)
        params.nil? ? send_method(action) : send_method(action, msg['params'])
      else
        logger.warn "INVALID ACTION: '#{action}'"
      end
    end

    def set_tilt(msg)
      Freenect.set_tilt(msg['tilt'].to_i)
      get_tilt_state
    end

    def get_tilt_state
      freenect_tilt_state = Freenect.get_tilt_state
      send({
        :action => :get_tilt_state,
        :data => {
          :titl_angle  => Freenect.get_tilt(freenect_tilt_state),
          :tilt_status => Freenect.get_tilt_status(freenect_tilt_state),
          :acc         => Freenect.get_acceleration(freenect_tilt_state)
      }})
    end

    def set_led(msg)
      led = msg['led'].to_sym
      Freenect.set_led(led)
      send({
        :action => :set_led,
        :data   => {:led => led},
      })
    end

    def get_video_mode_count
      send({
        :action => :get_video_mode_count,
        :data   => {:video_mode_count => Freenect.get_video_mode_count}
      })
    end

    def get_depth_mode_count
      send({
        :action => :get_depth_mode_count,
        :data   => {:depth_mode_count => Freenect.get_depth_mode_count}
      })
    end

    def get_depth_mode(data)
      depth_mode = Freenect.get_depth_mode(data['depth_mode_id'])
      send({
        :action => :get_depth_mode,
        :data   => frame_mode_to_hash(depth_mode).merge(:format => depth_mode[:format][:depth_format])
      })
    end

    def get_video_mode(data)
      video_mode = Freenect.get_video_mode(data['video_mode_id'])
      send({
        :action => :get_video_mode,
        :data   => frame_mode_to_hash(video_mode).merge(:format => video_mode[:format][:video_format])
      })
    end

    def send(msg)
      logger.info "SENDING: #{msg.inspect}"
      socket.send(msg.to_json)
    end

    def frame_mode_to_hash(frame_mode)
      {
        :resolution             => frame_mode[:resolution],
        :bytes                  => frame_mode[:bytes],
        :width                  => frame_mode[:width],
        :height                 => frame_mode[:height],
        :data_bits_per_pixel    => frame_mode[:data_bits_per_pixel],
        :padding_bits_per_pixel => frame_mode[:padding_bits_per_pixel],
        :framerate              => frame_mode[:framerate],
        :is_valid               => frame_mode[:is_valid]
      }
    end

  end
end
