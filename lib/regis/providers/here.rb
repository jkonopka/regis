module Regis::Provider

  class Here < Base

    def query_url(query)
      "#{protocol}://#{if query.coordinates? then 'reverse.' end}" \
        "geocoder.api.here.com/6.2/" \
        "#{if query.coordinates? then 'reverse' end}" \
        "geocode.json?" + url_query_string(query)
    end

    def search(query)
      raw_results = ::Regis::CachedResult.with_cache(self, query) {
        doc = fetch_data(query)
        unless doc['Response'] && doc['Response']['View']
          raise InvalidResponseError, "Expected response to contain 'Response' and 'View'"
        end
        view = doc['Response']['View']
        if view.nil? || !view.is_a?(Array) || view.empty?
          raise InvalidResponseError, "Invalid result data in response"
        end
        doc
      }
      Results.new(raw_results)
    end

    private

    def query_url_params(query)
      options = {
        :gen=>4,
        :app_id=>configuration[:app_id],
        :app_code=>configuration[:app_code]
      }

      if query.coordinates?
        super.merge(options).merge(
          :prox=>query.sanitized_text,
          :mode=>:retrieveAddresses
        )
      else
        super.merge(options).merge(
          :searchtext=>query.sanitized_text
        )
      end
    end

  end
end
