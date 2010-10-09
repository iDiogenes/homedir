require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'


spec = Gem::Specification.new do |s|
	s.name = 'homedir'
	s.version = '3.0.0'
	s.author = 'JD Trout'
	s.email = 'jd.trout@loni.ucla.edu'
	s.homepage = 'http://gibson-dev.loni.ucla.edu/ruby-scripts/homedir'
	s.platform = Gem::Platform::RUBY
	s.summary = "LONI tool to create and modify a user's home directory"
	s.has_rdoc = true

	s.files = FileList['lib/*'].to_a
	s.executables = ['homedir-cmd']
 
	# if there are any requirements on what version is needed this can be
	# modified
	s.add_dependency('net-ssh')

	s.description = <<-eos
homedir is a gem which has the ability of modifying Isilon directories.
	eos
end


Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_tar = true
end
