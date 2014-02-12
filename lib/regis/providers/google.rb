module Regis
  module Providers

    class Google

      def rate_limit_per_day
        2500
      end

      def geocode(request)
        params = {
          'address' => request.address,
          'sensor' => 'false'
        }

        components = []
        if (country = request.constraints[:country])
          components.push("country:#{country}")
        end
        if (country = request.constraints[:state])
          components.push("administrative_area:#{state}")
        end
        if components.any?
          params['components'] = components.join('|')
        end

        case request.location_hint
          when Point
            # TODO
          when Bounds
            query_params['bounds'] = request.location_hint.northwest.map { |p|
              [p.latitude, p.longitude].join(',')
            }.join('|')
        end

        result = HTTP.get_json("http://maps.googleapis.com/maps/api/geocode/json",
          params: params)
        return normalize(result)
      end

      private

        def normalize(result)
          # TODO
        end

    end

  end
end