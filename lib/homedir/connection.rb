module HomeDir
  class Connection
      
    # Start SSH session
    def ssh_start

      #begin
       ssh = ssh_open 
      #rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::timeout(10) => e
        # Notify isser if Auth or timeout. use raise none of this should be in here.  Should have several tries.
        # FATAL ERROR
        #$stderr.puts 'Could not connect to server!'
        #exit HomeDir::EXITCODES[:server_failure]
      #end
    end

    def ssh_stop(ssh)
      ssh_close(ssh) if ssh
    end

    private
    
    	# Opens an SSH connection if needed
    def ssh_open
      Net::SSH.start(SERVERS[:ssh], USER[:name])
    end

    # Closes an SSH connection if open
    def ssh_close(ssh)
      ssh.close
      puts "SSH Connection closed" if ssh.closed? 
      ssh = nil
    end
  end
end
