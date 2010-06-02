require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'


spec = Gem::Specification.new do |s|
	s.name = 'loni-mkhome'
	s.version = '2.0.0'
	s.author = 'Terence Honles'
	s.email = 'terence@honles.com'
	s.homepage = 'http://gibson-dev.loni.ucla.edu/ruby-scripts/create-home-directory'
	s.platform = Gem::Platform::RUBY
	s.summary = "LONI tool to create a user's home directory"
	s.has_rdoc = true

	s.files = FileList['lib/*'].to_a
	s.executables = ['loni-mkhome']
 
	# if there are any requirements on what version is needed this can be
	# modified
	s.add_dependency('net-ssh')

	s.description = <<-eos
loni-mkhome is a gem which packages the CreateHome class which encapsilates the
ability of creating the home directory of a LONI user.
	eos
end


Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_tar = true
end
