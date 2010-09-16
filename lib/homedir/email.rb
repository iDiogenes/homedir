module HomeDir
  class Email
    attr_accessor :msg

    def initialize(msg)
      @msg
    end

    	# Sends an email notifying a successful home directory creation
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

      Email.smtp_open.send_message message, ::HomeDir::NOTIFY[:from], ::HomeDir::NOTIFY[:to]
    end

    private

    def smtp_open
      smtp ||= Net::SMTP.start(SERVERS[:email], 25)
    end

    def smtp_close(smtp)
      smtp.close if smtp
      smtp = nil
    end

  end
end
