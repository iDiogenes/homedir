#!/usr/bin/env ruby
#HomeDir v1.0 9.29.09 (JD Trout)
#        v1.0f 10.18.09 (David Hasson)
#        v1.0g 1.25.10 (JD Trout)
#
#
#
#
require 'rubygems'
require 'net/ssh'
require 'net/smtp'

$server = "ifs3ki.loni.ucla.edu"
$email_svr = "smtp.loni.ucla.edu"
$email_from = "sysadm@loni.ucla.edu"
$email_to = "sysadm@loni.ucla.edu"

username = ARGV[0].to_s
username.downcase



def errorf(text)
  puts text
  exit
end

def email(username, homedir)
  date = Time.now
  msgstr = <<END_OF_MESSAGE
From: LONI Systems Administration <sysadm@loni.ucla.edu>
To: LONI Systems Administration <sysadm@loni.ucla.edu>
Subject: [loni-sys] The home directory created for <#{username}>.

   The home directory for <#{username}> has been created in 
    #{homedir} on #{date}. \n
    Cheers, 
    LONI Administration
END_OF_MESSAGE

  Net::SMTP.start("#{$email_svr}", 25) do |smtp|
    smtp.send_message msgstr, "#{$email_from}", "#{$email_to}"
  end
end

def c_hdir(username)
  begin
    Timeout::timeout(30) do
      
      ssh = Net::SSH.start($server, 'root')

      tmp = ssh.exec!("/usr/bin/ypcat passwd")
      passwd = []
      passwd = tmp.to_s.split("\n")

      #Search for userer in NIS
      tmp_user = []
      
      passwd.each do |string|
        separated = string.split(":")
        if separated.first == username
          tmp_user = string.split(":")
          break
        end
      end
      
      errorf("Could not find user #{username}.") unless tmp_user[0] == username


      # Define home dir and group
      homedir = "/ifs/home/#{username}"
      group = tmp_user[3]
      

      #Check for home dir existance
      hd_check = ssh.exec!("ls /ifs/home | grep -w #{username}")
      hd_check = hd_check.chomp unless hd_check == nil
      
      errorf("Home Directory #{homedir} already exists.") if hd_check == username

      #Create home dir & add quoate
      ssh.exec!("cp -R /ifs/home/template #{homedir} && chown -R #{username}:#{group} #{homedir} && chmod -R 755 #{homedir} && isi quota create --directory --path=#{homedir} --hard-threshold=3G --advisory-threshold=2.75G")

      #Check to see if home dir was created
      hd_done = ssh.exec!("ls /ifs/home | grep -w #{username}")
      hd_done = hd_done.chomp unless hd_done == nil
      if hd_done == username
        puts "Home Directory for #{username} was created successfully."
        email(username, homedir)
      end
      errorf("Home Directory #{homedir} was not created.") if hd_done == nil
    end
  end
end



# Run Program
errorf("Invalid username specified") if username =~ /[^a-zA-Z_]/

c_hdir(username)

