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

    def data_base
      "soulmate-data:#{type}"
    end

    def cache_base
      "soulmate-cache:#{type}"
    end

    def secondary_index_base
      "soulmate-secondary-index:#{type}"
    end
  end
end