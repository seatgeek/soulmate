module Soulmate

  class Loader < Base

    def load(items)
      # delete the sorted sets for this type
      # wrap in multi/exec?
      phrases = Soulmate.redis.smembers(base)
      phrases.each do |p|
        Soulmate.redis.del("#{base}:#{p}")
      end
      Soulmate.redis.del(base)

      # Redis can continue serving cached requests for this type while the reload is
      # occuring. Some requests may be cached incorrectly as empty set (for requests
      # which come in after the above delete, but before the loading completes). But
      # everything will work itself out as soon as the cache expires again.

      # delete the data stored for this type
      Soulmate.redis.del(database)

      items_loaded = 0
      items.each_with_index do |item, i|
        add(item)
        items_loaded += 1
        puts "added #{i} entries" if i % 100 == 0 and i != 0
      end

      items_loaded
    end

    # "id", "term", "score", "aliases", "data"
    def add(item = {})
      raise ArgumentError unless item["id"] && item["term"]
      
      # kill any old items with this id
      remove(item["id"])
      
      # store the raw data in a separate key to reduce memory usage
      Soulmate.redis.hset(database, item["id"], JSON.dump(item))
      phrase = ([item["term"]] + (item["aliases"] || [])).join(' ')
      prefixes_for_phrase(phrase).uniq.each do |p|
        Soulmate.redis.sadd(base, p) # remember this prefix in a master set
        Soulmate.redis.zadd("#{base}:#{p}", item["score"], item["id"]) # store the id of this term in the index
      end
    end

    def remove(id)
      prev_item = Soulmate.redis.hget(database, id)
      if prev_item
        prev_item = JSON.load(prev_item)
        # undo the operations done in add
        Soulmate.redis.hdel(database, prev_item["id"])
        phrase = ([prev_item["term"]] + (prev_item["aliases"] || [])).join(' ')
        prefixes_for_phrase(phrase).uniq.each do |p|
          Soulmate.redis.srem(base, p)
          Soulmate.redis.zrem("#{base}:#{p}", prev_item["id"])
        end
      end
    end
  end
end