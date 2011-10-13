require 'sinatra/base'
require 'soulmate'
require 'rack/contrib'

module Soulmate

  class Server < Sinatra::Base
    include Helpers
    
    use Rack::JSONP
    
    before do
      content_type 'application/json', :charset => 'utf-8'
    end
    
    get '/' do
      MultiJson.encode({ :soulmate => Soulmate::Version::STRING, :status   => "ok" })
    end
    
    get '/search' do
      raise Sinatra::NotFound unless (params[:term] and params[:types] and params[:types].is_a?(Array))
      
      limit = (params[:limit] || 5).to_i
      types = params[:types].map { |t| normalize(t) }
      term  = params[:term]
      
      results = {}
      types.each do |type|
        matcher = Matcher.new(type)
        results[type] = matcher.matches_for_term(term, :limit => limit, :lat => params[:lat], :long => params[:long])
      end
      
      MultiJson.encode({
        :term    => params[:term],
        :results => results
      })
    end
    
    not_found do
      content_type 'application/json', :charset => 'utf-8'
      MultiJson.encode({ :error => "not found" })
    end
    
  end
end
