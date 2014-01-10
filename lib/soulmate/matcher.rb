module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      options = { :limit => 5, :cache => true, :filter_by => {} }.merge(options)

      words = normalize(term).split(' ').reject do |w|
        w.size < Soulmate.min_complete or Soulmate.stop_words.include?(w)
      end.sort

      return [] if words.empty?

      filter_text = options[:filter_by].map do |key, value|
        "#{key.to_s.singularize}:#{value.join("|")}"
      end.join(":").downcase

      cachekey = "#{cachebase}:" + words.join('|') + ":" + filter_text

      if !options[:cache] || !Soulmate.redis.exists(cachekey) || Soulmate.redis.exists(cachekey) == 0
        interkeys = words.map { |w| "#{base}:#{w}" }
        options[:filter_by].each do |key, values|
          if values.length > 1
            filter_cache_key = "#{cachebase}:filters:#{normalize(key.to_s.singularize)}:" + values.join('|').downcase 
            if !Soulmate.redis.exists(filter_cache_key) || Soulmate.redis.exists(filter_cache_key) == 0 
              unionkeys = [] 
              values.each do |value|
                value = value.downcase.strip.gsub(/ /, '')
                unionkeys << filter_key(key.to_s.singularize.downcase, value.downcase)
              end
              Soulmate.redis.zunionstore(filter_cache_key, unionkeys) 
              Soulmate.redis.expire(filter_cache_key, 10 * 60)
            end
          else
            filter_cache_key = filter_key(key.to_s.singularize, values.first)
          end
          interkeys << filter_cache_key 
          end 
        Soulmate.redis.zinterstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end

      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      if ids.size > 0
        results = Soulmate.redis.hmget(database, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        results.map { |r| MultiJson.decode(r) }
      else
        []
      end
    end
  end
end
