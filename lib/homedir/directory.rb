module HomeDir
  class Directory
#    attr_accessor :server, :user
#
#    def initialize(server, user)
#      @server = server
#      @user = user
#    end

    def create(quotasize,usernames)
      ssh = Connection.new
      ssh = ssh.ssh_start
      usernames.delete("create")
      usernames.uniq.each do |username|
 
        # search for user in NIS
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

        raise IndexError.new("Could not find user #{username}.") if passwd[0] != username

        # pull out the group & home directory
        group = passwd[3]
        home = passwd[5]

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
      ssh.ssh_stop(ssh)
    end

    def modify(quotasize,usernames)
      ssh = Connection.new
      ssh = ssh.ssh_start
      usernames.delete("modify")

      if usernames.index "all" or "a"
        passwd = ssh.exec!("/usr/bin/ypcat passwd").split("\n")
        passwd.each do |passwd|
          passwd = passwd.split(':')

          home = passwd[5]

          # set the quota threshold 
          quota_thres =  quota_threshold(quotasize)

           ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")
        end

      elsif usernames.index "blank" or "b"
        #Add code to deal with isi quota ls in --path=/home/ifs

      else
        usernames.uniq.each do |username|
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

          # pull out the home directory
          home = passwd[5]

          # set the quota threshold
          quota_thres =  quota_threshold(quotasize)

          ssh.exec!("isi quota modify --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=#{quota_thres}")
        end
      end
     ssh.ssh_stop(ssh)
    end

    # Method for setting the isi quota threshold - curretly set to be 10% less than the quota size
    def quota_threshold(qs)
      storage = qs.slice(/[GMT]/)
      qs = sprintf('%0.2f',(qs.to_f/((1+0.10))))
      qs = quota_thres << storage

      return qs
    end
  end
end
