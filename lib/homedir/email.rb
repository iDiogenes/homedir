module HomeDir
  class Email
    

    	# Sends an email notifying a successful home directory creation
    def self.send(comment, name)
      date = Time.now

      message = <<-msg
    Subject: [loni-sys] Home directory info for #{name}.
  
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
      smtp = Email.smtp_open.send_message message, 'jtrout@loni.ucla.edu', 'jtrout@loni.ucla.edu'
      #smtp.smtp_close(smtp)
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
