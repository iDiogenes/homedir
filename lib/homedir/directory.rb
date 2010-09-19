module HomeDir
  class Directory
    
    def create(quotasize,usernames)
      #email = Email.new
      ssh = Connection.new
      ssh = ssh.ssh_start
      usernames.delete("create")
      usernames.uniq.each do |username|
 
        # search for user in NIS
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

        raise IndexError.new("Could not find user #{username}.") if passwd[0] != username

        # pull out the group & home directory
        group = passwd[3]
        home = "/ifs/home/#{passwd[0]}"

        # check for home directory existence
        hd_check = ssh.exec!("/usr/bin/test -d #{home} && echo exists")
        $stderr.puts "Home dir #{home} already exists" if hd_check.chomp == "exists"

        # set the quota threshold
        quota_thres =  quota_threshold(quotasize)

        # create home directory & add quota
        ssh.exec!("cp -R /ifs/home/template #{home} && chown -R #{username}:#{group} #{home} && chmod -R 755 #{home} && isi quota create --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")

        # set up pidgin
        ssh.exec!("sed -i 's/LONI_ACCOUNT_NAME/#{username}/' #{home}/.purple/accounts.xml")

        # check for home directory existence
        hd_check = ssh.exec!("test -d #{home} && echo exists") != "exists"
        $stderr.puts "Home Directory #{home} was not created" if hd_check.chomp != "exists"
          #raise RuntimeError.new("Home Directory #{home} was not created.")
      end
      ssh = Connection.new.ssh_stop(ssh)
    end

    def modify(quotasize,usernames)
      email = Email.new
      ssh = Connection.new
      ssh = ssh.ssh_start
      usernames.delete("modify")

      if usernames.index "all"
        passwd = ssh.exec!("/usr/bin/ypcat passwd").split("\n")
        passwd.each do |passwd|
          passwd = passwd.split(':')

          home = "/ifs/home/#{passwd[0]}"

          # set the quota threshold 
          quota_thres =  quota_threshold(quotasize)

           ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")
           message = "All users now have a home directory quota size of #{quotasize} with an advisory threshold of #{quota_thres}."
           email.email(message)
        end
      else
        usernames.uniq.each do |username|
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

          # pull out the home directory
          home = "/ifs/home/#{passwd[0]}"

          # set the quota threshold
          quota_thres =  quota_threshold(quotasize)

          ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")
          message = "User #{username}'s home directory quota was changed to #{quotasize} with an advisory threshold of #{quota_thres}."
          email.email(message, username)
        end
      end
     ssh = Connection.new.ssh_stop(ssh)
    end

    private 
    
    # Method for setting the isi quota threshold - curretly set to be 10% less than the quota size
    def quota_threshold(qs)
      storage = qs.slice(/[GMT]/)
      qs = sprintf('%0.2f',(qs.to_f/((1+0.10))))
      qs = qs << storage
      return qs
    end
  end
end
