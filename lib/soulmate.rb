require 'uri'
require 'multi_json'
require 'redis'

require 'soulmate/version'
require 'soulmate/helpers'
require 'soulmate/base'
require 'soulmate/matcher'
require 'soulmate/loader'

module Soulmate

  extend self

  MIN_COMPLETE = 2
  STOP_WORDS = ["vs", "at"]

  def redis=(url)
    @redis = nil
    @redis_url = url
    redis
  end

  def redis
    @redis ||= (
      url = URI(@redis_url || "redis://127.0.0.1:6379/0")

      ::Redis.new({
        :host => url.host,
        :port => url.port,
        :db => url.path[1..-1],
        :password => url.password
      })
    )
  end

end
