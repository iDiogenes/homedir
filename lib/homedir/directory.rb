module HomeDir
  class Directory
 
    def create(quotasize,usernames, ssh)
      usernames.delete("create")

      if usernames.index "all"
        username = ssh.exec!("/usr/bin/ypcat passwd").split("\n")

        username.each do |username|
          username = username.split(':')

          #raise IndexError.new("Could not find user #{username}.") if username[0] != username
 
          # pull out the user, group & home directory
          group = username[3]
          home = "/ifs/home/#{username[0]}"
          user = username[0]

          # create the home directory & email
          create_home(user, home, quotasize, ssh)


          # email what changed
          message = "User #{username}'s home directory was created with a quotasize of #{quotasize} and an advisory threshold of #{quota_thres}."
          Email.send(message, username)
        end
      else
        #raise IndexError.new("Could not find user #{username}.") if username[0] != username
        #handle specific users
      end
    end

    def modify(quotasize,usernames, ssh)
      usernames.delete("modify")

      if usernames.index "all"
        username = ssh.exec!("/usr/bin/ypcat passwd").split("\n")

        raise IndexError.new("Could not find user #{username}.") if username[0] != username

        username.uniq.each do |username|
          username = username.split(':')

          home = "/ifs/home/#{username[0]}"

          # set the quota threshold 
          quota_thres =  quota_threshold(quotasize)
          $stdout.puts "Advisory threshold is #{quota_thres}\n\n" if $VERBOSE

          $stdout.puts "Modifying quota for #{username} to be #{quotasize}\n\n" if $VERBOSE
          ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")

          # email what changed
          message = "All users now have a home directory quota size of #{quotasize} with an advisory threshold of #{quota_thres}."
          Email.send(message, "All LONI Users")
        end
      else
        usernames.uniq.each do |username|
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

          # pull out the home directory
          home = "/ifs/home/#{passwd[0]}"

          # set the quota threshold
          quota_thres =  quota_threshold(quotasize)
          $stdout.puts "Advisory threshold is #{quota_thres}\n\n" if $VERBOSE
          
          $stdout.puts "Modifying quota for #{username} to be #{quotasize}\n\n" if $VERBOSE
          ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")

           # quota checking
           quota_check(home, quotasize, ssh)

          # email what changed
          message = "User #{username}'s home directory quota was changed to #{quotasize} with an advisory threshold of #{quota_thres}."
          Email.send(message, username)
        end
      end
    end

    private 
    
    # Method for setting the isi quota threshold - curretly set to be 10% less than the quota size
    def quota_threshold(qs)
      size = qs.slice(/[GMT]/)
      qs = sprintf('%0.1f',(qs.to_f/((1+0.10))))
      qs = qs << size
      return qs
    end

    # Method for checking the quota change/creation
    def quota_check(home, quotasize, ssh)
      $stdout.puts "Checking to make sure quota was changed\n\n" if $VERBOSE
      qs_check = ssh.exec!("isi quota ls --path=#{home} | grep -c #{quotasize}")
      if qs_check.to_i == 1
        $stdout.puts "Quota check was successful\n\n" if $VERBOSE
      else
        raise StandardError.new("Quota check was NOT successful\n\n")
      end
    end

    # Method for creating the home directory
    def create_home(username, home, quotasize, ssh)
      $stdout.puts "Checking to see if a home directory for #{username} exists \n\n" if $VERBOSE

      # checking to see if the home directory exists
      if ssh.exec!("test -d #{home} && echo exists") == "exists\n"
        raise NameError.new("Home Directory #{home} already exists.")
      else
        $stdout.puts "Home directory for #{username} does not exists\n\n"
      end

      # set the quota threshold
      quota_thres =  quota_threshold(quotasize)
      $stdout.puts "Advisory threshold is #{quota_thres}\n\n" if $VERBOSE

      # create home directory & add quota
      $stdout.puts "Created quota for #{username} to be #{quotasize}\n\n" if $VERBOSE
      ssh.exec!("cp -R /ifs/home/template #{home} && chown -R #{username}:#{group} #{home} && chmod -R 755 #{home} && isi quota create --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")

      # set up pidgin
      $stdout.puts "Setting up pidgin for #{username}\n\n" if $VERBOSE
      ssh.exec!("sed -i 's/LONI_ACCOUNT_NAME/#{username}/' #{home}/.purple/accounts.xml")

      # check if home directory was created
      $stdout.puts "Checking to see if a homedirectory for #{username} was created \n\n" if $VERBOSE
      if ssh.exec!("test -d #{home} && echo exists") == "exists\n"
        $stdout.puts "Home Directory #{home} was successfully created\n\n"
      else
        raise StandardError.new("Home Directory for #{home} was NOT successful created\n\n")
      end

      # check to make sure quota as set
      quota_check(home, quotasize, ssh)

    end

    def modify_home(username, home, quotasize, ssh)
      # set the quota threshold
      quota_thres =  quota_threshold(quotasize)
      $stdout.puts "Advisory threshold is #{quota_thres}\n\n" if $VERBOSE

      $stdout.puts "Modifying quota for #{username} to be #{quotasize}\n\n" if $VERBOSE
      ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")

      # check to make sure quota as set
      quota_check(home, quotasize, ssh)
    end
  end
end
