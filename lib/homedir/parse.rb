module HomeDir
  class Parse

    def self.run(args)
      parse_arguments(args)
#      Need to put in some code to deal with parsing errors

      # Open SSH & SMTP connections
      #email = Email.new
      $stdout.puts "Openig new SSH connection" if $VERBOSE
      ssh = Connection.new.ssh_start

      if @usernames[0] == "create"
        Directory.new.create(@quotasize, @usernames, ssh)
      end
      
      if @usernames[0] == "modify"
        Directory.new.modify(@quotasize, @usernames, ssh)
      end
      
      $stdout.puts "Closing SSH connection" if $VERBOSE
      # Close SSH connection
      ssh = Connection.new.ssh_stop(ssh)
    end

    private

    def self.parse_arguments(args)
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
        
        opts.on('-v', '--verbose', 'Verbose mode') {

          $VERBOSE = true
          
        }
        

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
     end
     
     opts.parse!(args)
    end    
  end
end

