#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'

#def initialize
#  @quotasize  = nil
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
  #puts "quota size is #{@quotasize}"
  
  if @usernames[0] == "modify"
    puts @usernames
  end
  if @usernames[0] == "create"
    puts @usernames
  end

end

run


