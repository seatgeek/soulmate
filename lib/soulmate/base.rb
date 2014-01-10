module Soulmate
  
  class Base
    
    include Helpers
    
    attr_accessor :type
    
    def initialize(type)
      @type = normalize(type)
    end
    
    def base
      "soulmate-index:#{type}"
    end

    def database
      "soulmate-data:#{type}"
    end

    def filters
      "soulmate-filters:#{type}"
    end

    def cachebase
      "soulmate-cache:#{type}"
    end
  end
end