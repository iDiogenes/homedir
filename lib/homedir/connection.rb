module HomeDir
  class Connection
      
    # Start SSH session
    def ssh_start

      begin
       passwd = ask("Enter your password: ") { |q| q.echo = "*" }
       ssh = ssh_open(passwd)
      rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::timeout(10) 
        $stderr.puts 'Could not connect to server!\n\n'
      end
    end

    def ssh_stop(ssh)
      ssh_close(ssh) if ssh
    end

    private
    
    	# Opens an SSH connection if needed
    def ssh_open(passwd)
      Net::SSH.start(SERVERS[:ssh], USER[:name], :password => passwd)
    end

    # Closes an SSH connection if open
    def ssh_close(ssh)
      ssh.close
      if ssh.closed?
        $stdout.puts "SSH connection closed\n\n" if $VERBOSE
      end    
      ssh = nil
    end
  end
end
