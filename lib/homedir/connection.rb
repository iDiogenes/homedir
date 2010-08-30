module HomeDir
  class Connection

    attr_accessor :ssh
    def initilize()
      
    # Start SSH session
    def start(hostname, username)
      begin
        ssh_open(hostname, username)
      rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
        # Notify isser if Auth or timeout. use raise none of this should be in here.  Should have several tries.
        # FATAL ERROR
        $stderr.puts 'Could not connect to server!'
        exit EXITCODES[:server_failure]
      end
    end

    def exec
      #Call a block or pass in a block. Really cool block.
      #exec arguments are an argument and a block
      # Stop the SSH session
    end
    
    def stop
      ssh_close if ssh
    end

    private
    	# Opens an SSH connection if needed
    def ssh_open(hostname,username)
      ssh ||= Net::SSH.start(hostname, username)
    end


    # Closes an SSH connection if open
    def ssh_close
      ssh.close #check if this right
      ssh = nil
    end

  end
end
