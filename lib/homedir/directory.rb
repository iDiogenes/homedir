module HomeDir
  class Directory

    def create(close=true)
      raise ArgumentError.new('Invalid username specified') if not valid_username?

      Timeout::timeout(30) do
        ssh = CreateHome.ssh_open

        # search for user in NIS
        passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

        raise IndexError.new("Could not find user #{username}.") if passwd[0] != username

        # pull out the group
        group = passwd[3]

        # check for home directory existence
        if ssh.exec!("test -d #{home} && echo exists") == "exists"
          raise NameError.new("Home Directory #{home} already exists.")
        end

        # create home directory & add quota
        ssh.exec!("cp -R /ifs/home/template #{home} && chown -R #{username}:#{group} #{home} && chmod -R 755 #{home} && isi quota create --directory --path=#{home} --hard-threshold=3G --advisory-threshold=2.75G")

        # set up pidgin
        ssh.exec!("sed -i 's/LONI_ACCOUNT_NAME/#{username}/' #{home}/.purple/accounts.xml")

        # check for home directory existence
        if ssh.exec!("test -d #{home} && echo exists") != "exists"
          raise RuntimeError.new("Home Directory #{home} was not created.")
        end

        CreateHome.ssh_close if close
      end

      email(comment)
      CreateHome.smtp_close if close
    end

    def aclmod

    end


    private :email

	# Returns the path to a user's home directory
    def home
      "/ifs/home/#{username}"
    end

    attr_reader :username

    # Sets a username for home directory creation
    def username=(username)
      @username = username
      @valid_username = nil
    end

	# Checks to see if the username is valid username string
    def valid_username?
      if @valid_username == nil
        @valid_username = !(@username =~ /[^a-zA-Z_]/)
      end

      return @valid_username
    end
  end
end