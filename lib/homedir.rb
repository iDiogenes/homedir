require 'rubygems'
require 'etc'
require 'net/ssh'
require 'net/smtp'
require 'optparse'
require 'ostruct'
require 'yaml'


require 'homedir/connection'
require 'homedir/directory'
require 'homedir/email'
require 'homedir/main'

module HomeDir
  # Config file should be sitting right next to this file
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yaml'))

  # Servers that this script will interact with
  SERVERS = CONFIG[:servers]

  # Username that will be used to make connections
  USER = CONFIG[:username]

  # People to notify when this script makes changes
  NOTIFY = CONFIG[:notify]

  # Exit codes which this script will be using
  EXITCODES = CONFIG[:exitcodes]
end
