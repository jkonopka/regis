require_relative './base'

module Regis
  module Provider

    class Google < Base

      def query_url(query)
        "#{protocol}://maps.googleapis.com/maps/api/geocode/json?" + url_query_string(query)
      end

      def rate_limit_per_day
        2500
      end

      def search(query)
        raw_results = CachedResult.with_cache(self, query) {
          doc = fetch_data(query)
          case doc['status']
            when "OK"
              doc
            when "OVER_QUERY_LIMIT"
              raise OverQueryLimitError.new
            when "REQUEST_DENIED"
              raise RequestDenied.new
            when "INVALID_REQUEST"
              raise InvalidRequest.new
          end
        }
        raw_results ||= {'results' => []}
        Results.new(raw_results)
      end

      private

        def valid_response?(response)
          status = parse_json(response.body)["status"]
          super(response) and ['OK', 'ZERO_RESULTS'].include?(status)
        end

        def query_url_google_params(query)
          params = {
            (query.coordinates? ? :latlng : :address) => query.sanitized_text,
            :sensor => "false",
            :language => configuration.language
          }
          unless (bounds = query.options[:bounds]).nil?
            params[:bounds] = bounds.map{ |point| "%f,%f" % point }.join('|')
          end
          unless (region = query.options[:region]).nil?
            params[:region] = region
          end
          unless (components = query.options[:components]).nil?
            params[:components] = components.is_a?(Array) ? components.join("|") : components
          end
          params
        end

        def query_url_params(query)
          query_url_google_params(query).merge(
            :key => configuration.api_key
          ).merge(super)
        end

    end

  end
end