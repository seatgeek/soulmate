module Soulmate
  
  class Base
    
    include Helpers
    
    attr_accessor :type
    
    def initialize(type, soul=nil)
      @type = normalize(type)
      @soul = normalize(soul) unless soul == nil
    end
    
    def base
      if @soul
        "soulmate-index:#{@soul}:#{type}"
      else
        "soulmate-index:#{type}"
      end
    end

    def database
      if @soul
        "soulmate-data:#{@soul}:#{type}"
      else
        "soulmate-data:#{type}"
      end
    end

    def cachebase
      if @soul
        "soulmate-cache:#{@soul}:#{type}"
      else
        "soulmate-cache:#{type}"
      end
    end
  end
end