module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or STOP_WORDS.include?(w)
      end.sort

      options[:limit] ||= 5
      options[:filters] ||= {}

      cachekey = "#{cachebase}:" + words.join('|') + ":" + options[:filters].to_s

      if !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        
        interkeys += options[:filters].to_a.map do |filter|
          value = filter.last.downcase.strip.gsub(/ /, '')
          "#{base}:filters:#{filter.first}:#{value}"
        end
        p interkeys
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      ids.size > 0 ? Soulmate.redis.hmget(database, *ids).map { |r| JSON.parse(r) } : []
    end
  end
end