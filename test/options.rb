#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'net/ssh'

#def initialize
#  @quotasize  = nil
#  @ssh        = nil
#end

def parse_arguments(args)
opts = OptionParser.new do |opts|
  opts.banner = 'Usage: Place Holder'
  opts.separator ''
  opts.separator 'homedir is free software created at the Laboratory of Neuro Imaging (LONI)'
  opts.separator 'for the sole purpose of manipulating directories on an Isilon System'
  opts.separator ''

  opts.on('-c', '--create', 'Create home directory') {
    if ARGV[0] == nil
      $stderr.puts 'No usernames specified!'
    end

    @usernames = ["create"]
    ARGV.uniq.each do |username| 
     username = username.to_s.downcase
     break if username =~ /\-/
     @usernames << username
    end
  }
  

  opts.on('-m', '--modify', 'Modify home directory quota') {
   if ARGV[0] == nil
     $stderr.puts 'No usernames specified!'
   end

   @usernames = ["modify"]
   ARGV.uniq.each do |username| 
    username = username.to_s.downcase
    break if username =~ /\-/
    @usernames << username
   end
  }

    
  opts.on('-s', '--size', 'Set directory quota size') {
    qs = ARGV[0]
    unless qs =~ (/^(\d*\.?\d)[GTM]$/) #Make sure
      $stderr.puts "Incorrect size value" # Need to put in a proper exit code
      exit 1 #clean this cheese up
    end

    @quotasize = qs
    
  }


  opts.on('-h', '--help', 'Show this message') do 
    puts opts
    exit 1
  end
end

opts.parse!(args)
end


def run
  view = parse_arguments(ARGV)

  ssh ||= ssh_open

  directory_mod(ssh, @usernames,@quotasize)


end

def ssh_open
   Net::SSH.start('localhost', 'jtrout', :password => "passwd")
end


def directory(ssh,username,quotasize)


  username.delete("create")
  username.uniq.each do |username|
    passwd = ssh.exec!("cat /etc/passwd | grep '^#{username}:'").split(':') #If username does not exists split error capture error
    
    #$stderr.puts "Could not find user #{username}." if passwd[0] != username

    group = passwd[3]
    home = passwd[5]


     hd_check = ssh.exec!("/usr/bin/test -d #{home} && echo exists")
     $stderr.puts "Home dir #{home} already exists" if hd_check.chomp == "exists"

    storage = @quotasize.slice(/[GMT]/)
    quota_thres = sprintf('%0.2f',(@quotasize.to_f/((1+0.10))))
    quota_thres =  quota_thres << storage
   
    puts quota_thres




#    if ssh.exec!("/usr/bin/test -d /home/jtrout && echo exists") == "exists"
#			puts "Home Directory #{home} already exists."
#		end
    
  end


  #end
end

def directory_mod(ssh,username,quotasize)
  username.delete("modify")

  if username.index "all" or "a"
    
    passwd = ssh.exec!("cat /etc/passwd").split("\n")
    #passwd = passwd.split(':')
    #puts  passwd[1]
    passwd.each do |passwd|
      passwd = passwd.split(':')

      home = passwd[5]
      puts home

    end
    #puts passwd[0]
  end
#  username.uniq.each do |username|
#    passwd = ssh.exec!("cat /etc/passwd | grep '^#{username}:'").split(':') #If username does not exists split error capture error
#
#    #$stderr.puts "Could not find user #{username}." if passwd[0] != username
#
#    group = passwd[3]
#    home = passwd[5]
#
#
#     hd_check = ssh.exec!("/usr/bin/test -d #{home} && echo exists")
#     $stderr.puts "Home dir #{home} already exists" if hd_check.chomp == "exists"
#
#    storage = @quotasize.slice(/[GMT]/)
#    quota_thres = sprintf('%0.2f',(@quotasize.to_f/((1+0.10))))
#    quota_thres =  quota_thres << storage
#
#    puts quota_thres


#    if ssh.exec!("/usr/bin/test -d /home/jtrout && echo exists") == "exists"
#			puts "Home Directory #{home} already exists."
#		end

  #end


  #end
end

run


