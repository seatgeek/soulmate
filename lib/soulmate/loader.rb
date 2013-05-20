module Soulmate

  class Loader < Base

    def load(items)
      # delete the sorted sets for this type
      phrases = Soulmate.redis.smembers(base)
      Soulmate.redis.pipelined do
        phrases.each do |p|
          Soulmate.redis.del("#{base}:#{p}")
        end
        Soulmate.redis.del(base)
      end

      # Redis can continue serving cached requests for this type while the reload is
      # occuring. Some requests may be cached incorrectly as empty set (for requests
      # which come in after the above delete, but before the loading completes). But
      # everything will work itself out as soon as the cache expires again.

      # delete the data stored for this type
      Soulmate.redis.del(database)

      items.each_with_index do |item, i|
        add(item, :skip_duplicate_check => true)
      end
    end

    # "id", "term", "score", "aliases", "data"
    def add(item, opts = {})
      opts = { :skip_duplicate_check => false }.merge(opts)
      raise ArgumentError unless item["id"] && item["term"]
      
      # kill any old items with this id
      remove("id" => item["id"]) unless opts[:skip_duplicate_check]
      
      Soulmate.redis.pipelined do
        # store the raw data in a separate key to reduce memory usage
        Soulmate.redis.hset(database, item["id"], MultiJson.encode(item))
        phrase = ([item["term"]] + (item["aliases"] || [])).join(' ')
        prefixes_for_phrase(phrase).each do |p|
          Soulmate.redis.sadd(base, p) # remember this prefix in a master set
          Soulmate.redis.zadd("#{base}:#{p}", item["score"], item["id"]) # store the id of this term in the index
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
          phrase = ([prev_item["term"]] + (prev_item["aliases"] || [])).join(' ')
          prefixes_for_phrase(phrase).each do |p|
            Soulmate.redis.srem(base, p)
            Soulmate.redis.zrem("#{base}:#{p}", prev_item["id"])
          end
        end
      end
    end
  end
end
