module HomeDir
  class Main

    def initialize
      @quotasize  = nil
    end

    def run(args)
      
      parse_arguments(ARGV)
#      Need to put in some code to deal with parsing errors

      begin
        ssh_open
      rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
        #Error Connecting to server
        $stderr.puts 'Could not connect to server!' # Need to add some proper errors
      end

      

    end

    private

    def parse_arguments(args)
      opts = OptionParser.new do |opts|
        opts.banner = 'Usage: Place Holder'
        opts.separator ''
        opts.separator 'homedir is free software created at the Laboratory of Neuro Imaging (LONI)'
        opts.separator 'for the sole purpose of manipulating directories on an Isilon System'
        opts.separator ''

        opts.on('-c', '--create', 'Create home directory') {

          if ARGV[0] == nil
            $stderr.puts 'No usernames specified!' #This should not be handled here
          end

          usernames = []

          ARGV.uniq.each do |username|
            username.to_s.downcase
            usernames << username
          end

          return 'create', usernames

        }

        opts.on('-m', '--modify', 'Modify home directory quota') {

          if ARGV[0] == nil
            $stderr.puts 'No usernames specified!' #This should not be handled here
          end

          usernames = []

          ARGV.uniq.each do |username|
            username.to_s.downcase
            puts "Creating #{username}"   #This is just a place holder
          end

          return 'modify', usernames
          
        }

        opts.on('-s', '--size', 'Set directory quota size') {
          qs = ARGV[0]
          unless qs =~ (/^(\d*\.?\d)[GTM]$/) #Make sure
            $stderr.puts "Incorrect size value" # Need to put in a proper exit code
          end

          @quotasize = qs
        }

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
     end
     opts.parse!(args)
    end

    # Open SSH connection
    def ssh_open
      @ssh ||= Net::SSH.start(SERVERS[:ssh], 'root')
    end

    # Close SSH connection if open
    def ssh_close
      @ssh.close if ssh
      @ssh = nil
    end
    
  end
end

