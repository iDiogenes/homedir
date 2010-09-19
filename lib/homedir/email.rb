module HomeDir
  class Email
    #attr_accessor :msg

    #def initialize(msg)
   #   @msg
   # end

    	# Sends an email notifying a successful home directory creation
    def email(comment, name)
      date = Time.now

      message = <<-msg
  From: LONI Systems Administration <sysadm@loni.ucla.edu>
  To: LONI Systems Administration <jtrout@loni.ucla.edu>
  Subject: [loni-sys] Home directory info for <#{name}>.
  
      #{date}:
      
      Home directory info for #{name} is available, please see Additional Information.
     
      msg

      if comment
        message << <<-msg

      Additional Information:
      #{comment}
        msg
      end

      message << <<-msg

      This script was started by #{Etc.getlogin}

      Cheers, 
      LONI Administration
      msg

      #Email.smtp_open.send_message message, NOTIFY[:from], NOTIFY[:to]
      Email.smtp_open.send_message message, NOTIFY[:from], "jtrout@loni.ucla.edu"
    end

    private

    def self.smtp_open
      Net::SMTP.start(SERVERS[:email], 25)
    end

    def self.smtp_close(smtp)
      smtp.close if smtp
      smtp = nil
    end

  end
end
