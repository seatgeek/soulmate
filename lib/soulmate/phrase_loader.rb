module Soulmate

  class PhraseLoader < Loader

    # "id", "term", "score", "aliases", "data"
    def add(item, opts = {})
      opts = { :skip_duplicate_check => false }.merge(opts)
      raise ArgumentError unless item["id"] && item["term"]
      
      # kill any old items with this id
      remove("id" => item["id"]) unless opts[:skip_duplicate_check]
      
      Soulmate.redis.pipelined do
        # store the raw data in a separate key to reduce memory usage
        Soulmate.redis.hset(database, item["id"], MultiJson.encode(item))
        phrases = ([item["term"]] + (item["aliases"] || []))
        phrases.each do |phrase|
          prefixes_for_phrase(phrase).each do |p|
            Soulmate.redis.sadd(base, p) # remember this prefix in a master set
            Soulmate.redis.zadd("#{base}:#{p}", item["score"], item["id"]) # store the id of this term in the index
          end
        end
      end
    end

    # remove only cares about an item's id, but for consistency takes an object
    def remove(item)
      prev_item = Soulmate.redis.hget(database, item["id"])
      if prev_item
        prev_item = MultiJson.decode(prev_item)
        # undo the operations done in add
        Soulmate.redis.pipelined do
          Soulmate.redis.hdel(database, prev_item["id"])
          phrases = ([prev_item["term"]] + (prev_item["aliases"] || []))
          phrases.each do |phrase|
            prefixes_for_phrase(phrase).each do |p|
              Soulmate.redis.srem(base, p)
              Soulmate.redis.zrem("#{base}:#{p}", prev_item["id"])
            end
          end
        end
      end
    end
  end
end
