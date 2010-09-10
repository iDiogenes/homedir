   require 'rubygems'
   require 'net/ssh'
   
 
 Net::SSH.start('ifsnl.loni.ucla.edu', 'root', :password => "#{}1fsn{!") do |ssh|
   hostname = ssh.exec!("hostname")
  puts hostname
 end