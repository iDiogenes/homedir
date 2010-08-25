module HomeDir
  class Connection

    # Start SSH session
    def start
      begin
        ssh_open
      rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
        # FATAL ERROR
        $stderr.puts 'Could not connect to server!'
        exit EXITCODES[:server_failure]
      end
    end

    # Stop the SSH session
    def stop
      ssh_close
    end

    	# Opens an SSH connection if needed
    def ssh_open
      @ssh ||= Net::SSH.start(SERVERS[:ssh], 'root')
    end


    # Closes an SSH connection if open
    def self.ssh_close
      @ssh.close if @ssh
      @ssh = nil
    end

  end
end
