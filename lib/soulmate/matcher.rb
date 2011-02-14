module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or STOP_WORDS.include?(w)
      end.sort

      options[:limit] ||= 5

      cachekey = "#{cachebase}:" + words.join('|')

      if !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      ids.size > 0 ? Soulmate.redis.hmget(database, *ids).map { |r| JSON.parse(r) } : []
    end
  end
end