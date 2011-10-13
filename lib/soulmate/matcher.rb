require 'geokit'

module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      # Default limit of 0 means no limit.
      options = { :limit => 0, :cache => true }.merge(options)
      
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or STOP_WORDS.include?(w)
      end.sort

      return [] if words.empty?

      cachekey = "#{cachebase}:" + words.join('|')

      if !options[:cache] || !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      if ids.size > 0
        matches = Soulmate.redis.hmget(database, *ids)
          .reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
          .map { |r| MultiJson.decode(r) }
        if options[:lat] && options[:long]
          search_point = ::Geokit::LatLng.new(options[:lat], options[:long])
          matches.sort! {|a,b| ::Geokit::LatLng.new(a["lat"], a["long"]).distance_to(search_point) <=> ::Geokit::LatLng.new(b["lat"], b["long"]).distance_to(search_point) }
        end
        options[:geo_rank] ? matches.first(options[:geo_rank].to_i) : matches
      else
        []
      end
    end
  end
end
