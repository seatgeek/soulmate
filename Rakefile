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
require './lib/soulmate/version.rb'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name      = "soulmate"
  gem.version   = Soulmate::Version::STRING
  gem.homepage  = "http://github.com/seatgeek/soulmate"
  gem.license   = "MIT"
  gem.summary   = %Q{Redis-backed service for fast autocompleting - extracted from SeatGeek}
  gem.description = %Q{Soulmate is a tool to help solve the common problem of developing a fast autocomplete feature. It uses Redis's sorted sets to build an index of partial words and corresponding top matches, and provides a simple sinatra app to query them. Soulmate finishes your sentences.}
  gem.email     = "eric@seatgeek.com"
  gem.homepage  = "http://github.com/seatgeek/soulmate"
  gem.authors   = ["Eric Waller"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

REDIS_DIR = File.expand_path(File.join("..", "test"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "test.conf")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")
REDIS_LOCATION = ENV['REDIS_LOCATION']

task :default => :run

desc "Run tests and manage server start/stop"
task :run => [:start, :test, :stop]

desc "Run rcov and manage server start/stop"
task :rcoverage => [:start, :rcov, :stop]

desc "Start the Redis server"
task :start do
  redis_running = \
    begin
      File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
    rescue Errno::ESRCH
      FileUtils.rm REDIS_PID
      false
    end

  if REDIS_LOCATION
    system "#{REDIS_LOCATION}/redis-server #{REDIS_CNF}" unless redis_running
  else
    system "redis-server #{REDIS_CNF}" unless redis_running
  end
end

desc "Stop the Redis server"
task :stop do
  if File.exists?(REDIS_PID)
    Process.kill "INT", File.read(REDIS_PID).to_i
    FileUtils.rm REDIS_PID
  end
end
