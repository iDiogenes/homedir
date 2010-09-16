module HomeDir
  class Main
    # Config file should be sitting right next to this file
  	CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'CreateHome.yaml'))

  	# Servers that this script will interact with
  	SERVERS = CONFIG[:servers]
  	
  	# Username that will be used to make connections
  	USER = CONFIG[:username]

  	# People to notify when this script makes changes
  	NOTIFY = CONFIG[:notify]

  	# Exit codes which this script will be using
  	EXITCODES = CONFIG[:exitcodes]

#    def initialize
#      @quotasize  = nil
#      @usernames  = nil
#    end

    def run(args)
      parse_arguments(ARGV)
#      Need to put in some code to deal with parsing errors

      # Open connection to SSH server
      Connection.new(SERVERS[:ssh], USER[:username])
      ssh ||= Connection.ssh_start
      
      Directory.new(ssh)
      
      if @usernames[0] == "create"
        Directory.create(@quotasize, @usernames)
      end
      
      if @usernames[0] == "modify"
        Directory.modify(@quotasize, @usernames)
      end

      ssh_close(ssh) #Clean up ssh connections
      
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

          @usernames = ["create"]

          ARGV.uniq.each do |username|
            username = username.to_s.downcase
            break if username =~ /\-/
            @usernames << username
          end
          
        }

        opts.on('-m', '--modify', 'Modify home directory quota') {

          if ARGV[0] == nil
            $stderr.puts 'No usernames specified!' #This should not be handled here
          end

          @usernames = ["modify"]

          ARGV.uniq.each do |username|
            username = username.to_s.downcase
            break if username =~ /\-/
            @usernames << username
          end
          
        }

        opts.on('-s', '--size', 'Set directory quota size') {
          qs = ARGV[0]
          unless qs =~ (/^(\d*\.?\d)[GTM]$/) #Make sure the formatting is correct
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
      Net::SSH.start(SERVERS[:ssh], 'root')
    end

    # Close SSH connection if open
    def ssh_close(ssh)
      ssh.close if ssh
      ssh = nil
    end
    
  end
end

