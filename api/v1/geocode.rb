# encoding: utf-8

module Regis

  class V1 < Sinatra::Base

    post '/geocode' do
      search_address = params[:address]
      config = params[:config] || {}
      @data = Regis.search(search_address, config)
      # TODO when regis.search fails hard, @data comes back as an empty array... must fix that
      if(@data.rate_limited)
        response.status = 503
      end
      @data.to_json
    end

  end



end