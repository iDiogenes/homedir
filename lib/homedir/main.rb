module HomeDir
  class Main

    def run(args)
      parse_arguments(args)
#      Need to put in some code to deal with parsing errors
      
      if @usernames[0] == "create"
        Directory.new.create(@quotasize, @usernames)
      end
      
      if @usernames[0] == "modify"
        Directory.new.modify(@quotasize, @usernames)
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
  end
end

