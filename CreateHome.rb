#!/usr/bin/env ruby
#HomeDir v1.0 9.29.09 (JD Trout)
#        v1.0f 10.18.09 (David Hasson)
#        v1.0g 1.25.10 (JD Trout)
#        v2  6.1.10 (Terence Honles)
#
#
#
require 'rubygems'

require 'net/ssh'
require 'net/smtp'
require 'yaml'

# A helper library to create a user's home directory
class CreateHome
	# Config file should be sitting right next to this file
	CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'CreateHome.yaml'))

	# Servers that this script will interact with
	SERVERS = CONFIG[:servers]

	# People to notify when this script makes changes
	NOTIFY = CONFIG[:notify]

	# Exit codes which this script will be using
	EXITCODES = CONFIG[:exitcodes]

	# Creates the home directory for the specified user
	#
	# @param username String specifying the username
	def self.main(username)
		if not username
			puts 'No username specified'
			exit EXITCODES[:missing_arguments]
		end

		begin
			# try to create the user's home directory
			CreateHome.new(username).create
			puts "Home Directory for #{username} was created successfully."
		rescue ArgumentError => e
			puts e
			exit EXITCODES[:invalid_username]
		rescue SocketError, Net::SSH::AuthenticationFailed => e
			puts 'Could not connect to server!'
			exit EXITCODES[:server_failure]
		rescue IndexError => e
			puts e
			exit EXITCODES[:invalid_username]
		rescue NameError => e
			puts e
			exit EXITCODES[:directory_exists]
		rescue RuntimeError => e
			puts e
			exit EXITCODES[:creation_error]
		end
	end


	# Initializes a CreateHome instance
	#
	# @param username Username to use to create the directory
	def initialize(username)
		@username = username.downcase
	end

	# Creates and sets up a user's home directory
	def create
		raise ArgumentError.new('Invalid username specified') if not valid_username?

		Timeout::timeout(30) do
			Net::SSH.start(SERVERS[:ssh], 'root') do |ssh|

				# search for user in NIS
				passwd = ssh.exec!("/usr/bin/ypcat passwd | grep '^#{username}:'").split(':')

				raise IndexError.new("Could not find user #{username}.") if passwd[0] != username

				# pull out the group
				group = passwd[3]
				
				# check for home directory existence
				if ssh.exec!("test -d #{home} && echo exists") == "exists"
					raise NameError.new("Home Directory #{home} already exists.")
				end

				# create home directory & add quota
				ssh.exec!("cp -R /ifs/home/template #{home} && chown -R #{username}:#{group} #{home} && chmod -R 755 #{home} && isi quota create --directory --path=#{home} --hard-threshold=3G --advisory-threshold=2.75G")

				# check for home directory existence
				if ssh.exec!("test -d #{home} && echo exists") != "exists"
					raise RuntimeError.new("Home Directory #{home} was not created.")
				end
			end
		end

		email
	end


	# Sends an email notifying a successful home directory creation
	def email
		date = Time.now

		message = <<-msg
From: LONI Systems Administration <sysadm@loni.ucla.edu>
To: LONI Systems Administration <sysadm@loni.ucla.edu>
Subject: [loni-sys] The home directory created for <#{username}>.

   The home directory for <#{username}> has been created in 
    #{home} on #{date}. \n
    Cheers, 
    LONI Administration
		msg

		Net::SMTP.start(SERVERS[:email], 25) do |smtp|
			smtp.send_message message, NOTIFY[:from], NOTIFY[:to]
		end
	end

	private :email

	# Returns the path to a user's home directory
	def home
		"/ifs/home/#{username}"
	end

	attr_reader :username

	# Sets a username for home directory creation
	def username=(username)
		@username = username
		@valid_username = nil
	end

	# Checks to see if the username is valid username string
	def valid_username?
		if @valid_username == nil
			@valid_username = !(@username =~ /[^a-zA-Z_]/)
		end

		return @valid_username
	end
end



# If we're running this as a script
if __FILE__ == $0
	CreateHome.main ARGV[0]
end
