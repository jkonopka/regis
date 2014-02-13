# encoding: utf-8

module Regis

  class V1 < Sinatra::Base

    post '/geocode' do
      search_address = params[:address]
      @data = Regis.search(search_address)
      @data.to_json
    end

  end



end