#!/usr/bin/env ruby

require 'rubygems'

require 'etc'
require 'net/ssh'
require 'net/smtp'
require 'optparse'
require 'ostruct'
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
	# @param args List of arguments
	def self.main(args=nil)
		options, usernames, parser = parse(args)

		if usernames.length == 0
			$stderr.puts 'No usernames specified!'
			$stderr.puts parser
			# FATAL ERROR
			exit EXITCODES[:missing_arguments]
		end

		errors = []

		begin
			ssh_open
		rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
			# FATAL ERROR
			$stderr.puts 'Could not connect to server!'
			exit EXITCODES[:server_failure]
		end

		usernames.uniq.each do |username|
			begin
				# try to create the user's home directory
				CreateHome.new(username).create(close=false, comment=options.comment)
				puts "Home Directory for #{username} was created successfully."
			rescue ArgumentError => e
				errors << {:string => "#{e}: #{username}", :code => EXITCODES[:invalid_username]}
			rescue SocketError, Net::SSH::AuthenticationFailed, Timeout::Error => e
				# FATAL ERROR
				$stderr.puts 'Could not connect to server!'
				exit EXITCODES[:server_failure]
			rescue IndexError => e
				errors << {:string => "#{e}: #{username}", :code => EXITCODES[:invalid_username]}
			rescue NameError => e
				errors << {:string => "#{e}: #{username}", :code => EXITCODES[:directory_exists]}
			rescue RuntimeError => e
				errors << {:string => "#{e}: #{username}", :code => EXITCODES[:creation_error]}
			end
		end

		ssh_close

		# print all the problems on their own line
		$stderr.puts errors.map{|e| e[:string]}.join("\n")

		# exit with the BITWISE OR of all the exit codes (don't worry they are disjoint)
		exit errors.map {|e| e[:code]}.push(0).reduce {|exitcode, code| exitcode | code}
	end

	# Parses a list of arguments
	def self.parse(args=nil)
		args = (args ? args : ARGV).clone

		options = OpenStruct.new

		parser = OptionParser.new do |p|
			p.banner = "Usage #{$0} [options] username [username] ..."
			p.on('-c', '--comment COMMENT',
					'Add comment to email message') do |comment|
				options.comment = comment
			end

			p.on('-h', '--help', 'Show this') do |h|
				puts p
				exit
			end
		end

		parser.parse!(args)

		return options, args, parser
	end


	# opens an SSH connection if needed
	def self.smtp_open
		@smtp ||= Net::SMTP.start(SERVERS[:email], 25)
	end


	# closes an SSH connection if open
	def self.smtp_close
		@smtp.close if @smtp
		@smtp = nil
	end


	# opens an SSH connection if needed
	def self.ssh_open
		@ssh ||= Net::SSH.start(SERVERS[:ssh], 'root')
	end


	# closes an SSH connection if open
	def self.ssh_close
		@ssh.close if @ssh
		@ssh = nil
	end


	# Initializes a CreateHome instance
	#
	# @param username Username to use to create the directory
	def initialize(username, comment=nil)
		@username = username.downcase
	end

	# Creates and sets up a user's home directory
	def create(close=true)
		raise ArgumentError.new('Invalid username specified') if not valid_username?

		Timeout::timeout(30) do
			ssh = CreateHome.ssh_open

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

			# set up pidgin
			ssh.exec!("sed -i 's/LONI_ACCOUNT_NAME/#{username}/' #{home}/.purple/accounts.xml")

			# check for home directory existence
			if ssh.exec!("test -d #{home} && echo exists") != "exists"
				raise RuntimeError.new("Home Directory #{home} was not created.")
			end

			CreateHome.ssh_close if close
		end

		email(comment)
		CreateHome.smtp_close if close
	end


	# Sends an email notifying a successful home directory creation
	def email(comment=nil)
		date = Time.now

		message = <<-msg
From: LONI Systems Administration <sysadm@loni.ucla.edu>
To: LONI Systems Administration <sysadm@loni.ucla.edu>
Subject: [loni-sys] The home directory created for <#{username}>.

   The home directory for <#{username}> has been created in 
    #{home} on #{date}.
		msg

		if comment
			message << <<-msg

    Additional information:
    #{comment}
			msg
		end

		message << <<-msg

    This script was started by #{Etc.getlogin}

    Cheers, 
    LONI Administration
		msg

		CreateHome.smtp_open.send_message message, NOTIFY[:from], NOTIFY[:to]
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
	CreateHome.main
end
