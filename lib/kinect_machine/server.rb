module KinectMachine
  class Server

    MODES = [:command, :video, :depth]
    @mode_status = {:command => false, :video => false, :depth => false}

    class << self
      attr_accessor :mode_status
    end

    attr_reader :socket, :mode

    def initialize(socket)
      @socket, @mode = socket, nil
    end

    def close
      Server.mode_status[mode] = false
    end

    def logger; KinectMachine.logger; end

    def process_msg(msg)
      logger.info "RECEIVED MESSAGE ON SOCKET: #{socket.inspect}"
      begin
        msg = JSON.parse(msg)
      rescue Exception => error
        send_error(nil, nil, error.message)
      end
      action, params = msg['action'].to_sym, msg['params']
      logger.info "ACTION: '#{action}'"
      logger.info "PARAMS: '#{params.inspect}'"
      if respond_to?(action)
        begin
          params.nil? ? send_method(action) : send_method(action, msg['params'])
        rescue Exception => error
          logger.error error.message
          send_error(action, params, error.message)
        end
      else
        send_error(action, params, "INVALID ACTION: '#{action}'")
      end
    end

    def set_mode(data)
      if @mode = data['mode']
        @mode = @mode.to_sym
        raise('invalid mode') unless MODES.include?(mode)
        if Server.mode_status[mode]
          socket.close_connection
          raise "MODE '#{mode}' in use"
        end
        logger.info "ADDING '#{mode}' MODE"
        Server.mode_status[mode] = true
        extend(eval(mode[0].upcase+mode[1..-1]+'Server'))
        send({:action => :set_mode})
     else
        raise 'MODE PARAM MISSING'
      end
    end

    def send(msg)
      logger.info "SUCCESS SENDING: #{msg.inspect}"
      socket.send(msg.merge(:status => :success).to_json)
    end

    def send_error(action, params, error_msg)
      msg = {:status => :error, :message => error_msg, :action => action, :params => params}
      logger.info "ERROR SENDING: #{msg}"
      socket.send(msg.to_json)
    end

  end
end
