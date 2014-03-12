module Regis
  class V1 < Sinatra::Base

    post '/geocode' do
      search_address = params[:address]
      config = params[:config] || {}
      @data = Regis.search(search_address, config)
      halt 503, "Rate-limited" if @data.rate_limited
      @data.to_json
    end

  end
end