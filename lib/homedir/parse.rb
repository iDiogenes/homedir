module HomeDir
  class Parse

    def self.run(args)
      parse_arguments(args)
#      Need to put in some code to deal with parsing errors

      # Open SSH & SMTP connections
      $stdout.puts "\nOpenig new SSH connection\n\n" if $VERBOSE
      ssh = Connection.new.ssh_start

      if @usernames[0] == "create"
        Directory.new.create(@quotasize, @usernames, ssh)
      end
      
      if @usernames[0] == "modify"
        Directory.new.modify(@quotasize, @usernames, ssh)
      end

      # Close SSH connection
      $stdout.puts "Closing SSH connection\n\n" if $VERBOSE
      Connection.new.ssh_stop(ssh)
    end

    private

    def self.parse_arguments(args)

      if args[0] == nil
        $stderr.puts "\nPlease run -h or --help for more information\n\n"
        exit
      end

      opts = OptionParser.new do |opts|
        opts.banner = 'Isilon directory manipulator'
        opts.separator ''
        opts.separator 'homedir is free software created at the Laboratory of Neuro Imaging (LONI)'
        opts.separator 'for the sole purpose of manipulating directories on an Isilon System'
        opts.separator ''
        opts.separator 'Examples: ./homedir-cmd -m all -s 3.5G or ./homedir-cmd -c bobjones -s 4G'
        opts.separator ''

        opts.on('-c', '--create', 'Create home directory') {

          @usernames = ["create"]

          ARGV.uniq.each do |username|
            username = username.to_s.downcase
            break if username =~ /\-/
            @usernames << username
          end
          
        }

        opts.on('-m', '--modify', 'Modify home directory quota') {
          
          @usernames = ["modify"]

          ARGV.uniq.each do |username|
            username = username.to_s.downcase
            break if username =~ /\-/
            @usernames << username
          end
          
        }

        opts.on('-s', '--size', 'Set directory quota size') {
          qs = ARGV[0]
          
          unless qs =~ (/^(\d+\.?\d*)[GTM]$/) #Make sure the formatting is correct
            $stderr.puts "\nIncorrect size value, please use: M,G,T\n\n" 
            exit
          end

          # Convert size into float.  This is necessary because of quota checking in directory class
          size = qs.slice(/[GMT]/)
          qs = sprintf('%0.1f',(qs.to_f)).to_f # Isilon can only compute float to the thenth's place
          if qs > 9
            qs = sprintf('%0.0f',(qs.to_f)).to_i  # Isilon rounds after 9
          end

          qs = qs.to_s << size # convert to string and append size

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

