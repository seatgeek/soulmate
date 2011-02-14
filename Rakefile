require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "soulmate"
  gem.homepage = "http://github.com/seatgeek/soulmate"
  gem.license = "MIT"
  gem.summary = %Q{Redis-backed service that provides fast autocompleting - extracted from SeatGeek}
  gem.description = %Q{Soulmate is a tool to help solve the common problem of developing a fast autocomplete feature. It uses Redis's sorted sets to build an index of partial words and corresponding top matches, and provides a simple sinatra app to query them. Soulmate finished your sentences.}
  gem.email = "eric@seatgeek.com"
  gem.authors = ["Eric Waller"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'redis',   '>= 2.0'
  gem.add_runtime_dependency 'vegas',   '>= 0.1.0'
  gem.add_runtime_dependency 'sinatra', '>= 1.0'
  gem.add_runtime_dependency 'json',    '~> 1.4.6'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "soulmate #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
