#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'homedir'


# Run the program
HomeDir::Main.new.run(ARGV)