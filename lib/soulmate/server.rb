require 'sinatra/base'
require 'soulmate'

module Soulmate

  class Server < Sinatra::Base
    include Helpers
    
    before do
      content_type 'application/json', :charset => 'utf-8'
    end
    
    get '/' do
      JSON.pretty_generate({ :soulmate => Soulmate::Version::STRING, :status   => "ok" })
    end
    
    get '/search' do
      raise Sinatra::NotFound unless (params[:term] and params[:types] and params[:types].is_a?(Array))
      
      limit = (params[:limit] || 5).to_i
      types = params[:types].map { |t| normalize(t) }
      term  = params[:term]
      
      results = {}
      types.each do |type|
        matcher = Matcher.new(type)
        filters = params[:filters] && params[:filters][type] ? params[:filters][type] : {}
        results[type] = matcher.matches_for_term(term, :limit => limit, :filters => filters)
      end
      
      JSON.pretty_generate({
        :term    => params[:term],
        :results => results
      })
    end
    
    not_found do
      content_type 'application/json', :charset => 'utf-8'
      JSON.pretty_generate({ :error => "not found" })
    end
    
  end
end
