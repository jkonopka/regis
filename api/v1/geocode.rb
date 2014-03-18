module Regis
  class V1 < Sinatra::Base

    post '/geocode' do
      search_address = params[:address]
      options = params[:config] || {}

      @result = Regis.search(Query.new(search_address), options)
      JSON.dump({data: @result.as_json})
    end

    error InvalidQueryError do |e|
      halt 400, e.message
    end

    error RateLimitedError do |e|
      halt 503, e.message
    end

    error Timeout::Error do |e|
      halt 503, 'Timeout'
    end

  end
end