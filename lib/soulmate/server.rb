require 'sinatra/base'
require 'soulmate'

module Soulmate

  class Server < Sinatra::Base
    include Helpers
    
    before do
      content_type 'application/json', :charset => 'utf-8'
    end
    
    get '/' do
      '{ "soulmate": 1.0, "status": "ok" }'
    end
    
    get '/search' do
      limit = (params[:limit] || 5).to_i
      types = params[:types].map { |t| normalize(t) }
      term  = params[:term]
      
      results = {}
      types.each do |type|
        matcher = Soulmate::Matcher.new(type)
        results[type] = matcher.matches_for_term(term, :limit => limit)
      end
      
      JSON.pretty_generate({
        :term    => params[:term],
        :results => results
      })
    end
    
    not_found do
      '{ "error": "not found" }'
    end
    
  end
end
