module HomeDir
  class Connection

    attr_accessor :server :user
    
    def initilize(server, user)
      @server = server
      @user = user
    end
      
    # Start SSH session
    def ssh_start
      begin
        ssh = ssh_open
      rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
        # Notify isser if Auth or timeout. use raise none of this should be in here.  Should have several tries.
        # FATAL ERROR
        $stderr.puts 'Could not connect to server!'
        exit EXITCODES[:server_failure]
      end
      return ssh
    end

    def ssh_stop
      ssh_close if ssh
    end

    private
    	# Opens an SSH connection if needed
    def ssh_open
      ssh ||= Net::SSH.start(@server, @user)
    end

    # Closes an SSH connection if open
    def ssh_close
      ssh.close 
      ssh = nil
    end

  end
end
