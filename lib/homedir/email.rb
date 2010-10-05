module HomeDir
  class Email
    

    	# Sends an email notifying a successful home directory creation
    def self.send(comment, name)
      date = Time.now

      message = <<MESSAGE
From: LONI Systems Administration <sysadm@loni.ucla.edu>
To: JD Trout <jtrout@loni.ucla.edu>
Subject: [loni-sys] Home directory info for <#{name}>

#{date}:

Home directory info for #{name} is available, please see Additional Information.


Additional Information:
#{comment}

This script was started by #{Etc.getlogin}

Cheers,
LONI Administration
MESSAGE
   
      smtp = Email.smtp_open
      smtp.send_message message, NOTIFY[:from], NOTIFY[:to]
      smtp = Email.smtp_close(smtp)
    end

    private

    def self.smtp_open
      Net::SMTP.start(SERVERS[:email], 25)
    end

    def self.smtp_close(smtp)
      smtp.finish if smtp
      smtp = nil
    end

  end
end
