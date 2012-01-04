module KinectMachine
  class MessageDelegate
    def receive_data(data)
      send_data(data)
    end      
  end
end