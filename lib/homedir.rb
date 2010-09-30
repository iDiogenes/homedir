require 'rubygems'
require 'bundler/setup'
require 'etc'
require 'net/ssh'
require 'net/smtp'
require 'optparse'
require 'yaml'


require File.expand_path(File.dirname(__FILE__) + '/homedir/connection')
require File.expand_path(File.dirname(__FILE__) + '/homedir/directory')
require File.expand_path(File.dirname(__FILE__) + '/homedir/email')
require File.expand_path(File.dirname(__FILE__) + '/homedir/parse')

module HomeDir
  # Config file should be sitting right next to this file
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'HomeDirConf.yaml'))

  # Servers that this script will interact with
  SERVERS = CONFIG[:servers]
  
  # Username that will be used to make connections
  USER = CONFIG[:user]
  
  # People to notify when this script makes changes
  NOTIFY = CONFIG[:notify]

  # Exit codes which this script will be using
  EXITCODES = CONFIG[:exitcodes]
  
  # Set global variable for verbose
  $VERBOSE = nil
end
