# encoding: utf-8

module Regis

  class V1 < Sinatra::Base

    post '/geocode' do
      search_address = params[:address]
      @data = Regis.search(search_address)
      if(@data.rate_limited)
        response.status = 503
      end
      @data.to_json
    end

  end



end