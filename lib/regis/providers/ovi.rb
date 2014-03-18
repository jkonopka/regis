require_relative './base'

module Regis::Provider

  class Ovi < Base

    def query_url(query)
      "#{protocol}://where.desktop.mos.svc.ovi.com/json?" + url_query_string(query)
    end

    def rate_limit_per_day
      # TODO: Is this correct?
      50000
    end

    def search(query)
      raw_results = ::Regis::CachedResult.with_cache(self, query) {
        fetch_data(query)
      }
      Results.new(raw_results)
    end

    private

    def query_url_params(query)
      options = {
        :dv=>"OviMapsAPI",
        :la=>"en-US",
        :vi=>"where",
        :lat=>0,
        :lon=>0,
      }

      if query.coordinates?
        super.merge(options).merge(
          :prox=>query.sanitized_text,
          :mode=>:retrieveAddresses
        )
      else
        super.merge(options).merge(
          :q=>query.sanitized_text
        )
      end
    end

  end

end