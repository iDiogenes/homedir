Gem::Specification.new do |s|
  s.name = "homedir"
  s.version = "0.1"
  s.authors = ["JD Trout"]
  s.date = "2010-08-19"
  s.summary = %q{Home Directory Manipulation}
  s.description = %q{Homedir is a Home Directory management script.}
  s.homepage = "http://gibson-dev.loni.ucla.edu/+sys-admin/ruby-scripts/homedir"
  s.email = "jd.trout@loni.ucla.edu"
  s.files = %w( README.rdoc Rakefile LICENSE )
  s.files += Dir.glob("lib/**/*")
  s.files += Dir.glob("test/**/*")
  s.has_rdoc = false
end