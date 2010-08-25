module HomeDir
  class Session

    # Parses a list of arguments
    def self.parse(args=nil)
      args = (args ? args : ARGV).clone

      options = OpenStruct.new

      parser = OptionParser.new do |p|
        p.banner = "Usage #{$0} [options] username [username] ..."
        p.on('-c', '--comment COMMENT',
            'Add comment to email message') do |comment|
          options.comment = comment
        end

        p.on('-h', '--help', 'Show this') do |h|
          puts p
          exit
        end
      end

      parser.parse!(args)

      return options, args, parser
    end

    # Sending email
    def email(comment=nil)
      date = Time.now

      message = <<-msg
From: LONI Systems Administration <sysadm@loni.ucla.edu>
To: LONI Systems Administration <sysadm@loni.ucla.edu>
Subject: [loni-sys] The home directory created for <#{username}>.

The home directory for <#{username}> has been created in
  #{home} on #{date}.
  msg

      if comment
        message << <<-msg

        Additional information:
        #{comment}
        msg
      end

      message << <<-msg

      This script was started by #{Etc.getlogin}

      Cheers,
      LONI Administration
      msg

      CreateHome.smtp_open.send_message message, NOTIFY[:from], NOTIFY[:to]
    end
  end
end
