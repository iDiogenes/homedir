module HomeDir
  class Directory
    attr_accessor :ssh
    
    def initialize(ssh)
      @ssh = ssh
    end

    def create(quotasize,usernames)
      
      usernames.uniq.each do |username|
 
        # search for user in NIS
        passwd = @ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

        raise IndexError.new("Could not find user #{username}.") if passwd[0] != username

        # pull out the group
        group = passwd[3]

        # check for home directory existence
        if @ssh.exec!("test -d #{home} && echo exists") == "exists"
          raise NameError.new("Home Directory #{home} already exists.")
        end

        # create home directory & add quota
        @ssh.exec!("cp -R /ifs/home/template #{home} && chown -R #{username}:#{group} #{home} && chmod -R 755 #{home} && isi quota create --directory --path=#{home} --hard-threshold=#{quotasize} --advisory-threshold=2.75G")

        # set up pidgin
        @ssh.exec!("sed -i 's/LONI_ACCOUNT_NAME/#{username}/' #{home}/.purple/accounts.xml")

        # check for home directory existence
        if @ssh.exec!("test -d #{home} && echo exists") != "exists"
          raise RuntimeError.new("Home Directory #{home} was not created.")
        end
      end
    end

    def aclmod

    end
