require_relative '../providers/google'

class Regis::Provider::Google

  class Results

    attr_reader :results
    attr_reader :raw_results

    def initialize(raw_results)
      @raw_results = raw_results
      @results = raw_results['results'].map { |raw| Result.new(raw) }
    end

    def as_json(*args)
      @results.map { |r| r.as_json(*args) }
    end

    def eql?(other)
      return other.is_a?(Results) &&
        @results == other.results
    end
    alias_method :==, :eql?

  end

  class Result

    attr_reader :raw_result

    def initialize(data)
      @raw_result = data
    end

    def eql?(other)
      return other.is_a?(Result) &&
        @raw_result == other.raw_result
    end
    alias_method :==, :eql?

    def as_json(*args)
      return {
        "location" => {
          "lat" => latitude,
          "lng" => longitude,
          "location_type" => location_type.downcase,
          "result_type" =>result_type,
          "accuracy" => accuracy,
          "confidence" => confidence
        },
        "address" => {
          "formatted_address" => formatted_address,
          "country" => country_code,
          "state" => state_code,
          "county" => sub_state_code,
          "city" => city,
          "street" => street_address,
          "house_number" => street_number,
          "postal_code" => postal_code
        }
      }
    end

    private

      def coordinates
        ['lat', 'lng'].map{ |i| geometry['location'][i] }
      end

      def address(format = :full)
        formatted_address
      end

      def neighborhood
        if neighborhood = address_components_of_type(:neighborhood).first
          neighborhood['long_name']
        end
      end

      def city
        fields = [:locality, :sublocality,
          :administrative_area_level_3,
          :administrative_area_level_2]
        fields.each do |f|
          if entity = address_components_of_type(f).first
            return entity['long_name']
          end
        end
        return nil # no appropriate components found
      end

      def state
        if state = address_components_of_type(:administrative_area_level_1).first
          state['long_name']
        end
      end

      def state_code
        if state = address_components_of_type(:administrative_area_level_1).first
          state['short_name']
        end
      end

      def sub_state
        if state = address_components_of_type(:administrative_area_level_2).first
          state['long_name']
        end
      end

      def county
        if state = address_components_of_type(:administrative_area_level_2).first
          state['long_name']
        end
      end


      def sub_state_code
        if state = address_components_of_type(:administrative_area_level_2).first
          state['short_name']
        end
      end

      def country
        if country = address_components_of_type(:country).first
          country['long_name']
        end
      end

      def country_code
        if country = address_components_of_type(:country).first
          country['short_name']
        end
      end

      def postal_code
        if postal = address_components_of_type(:postal_code).first
          postal['long_name']
        end
      end

      def route
        if route = address_components_of_type(:route).first
          route['long_name']
        end
      end

      def street_number
        if street_number = address_components_of_type(:street_number).first
          street_number['long_name']
        end
      end

      def street_address
        [street_number, route].compact.join(' ')
      end

      def types
        @raw_result['types']
      end

      def formatted_address
        @raw_result['formatted_address']
      end

      def address_components
        @raw_result['address_components']
      end

      ##
      # Get address components of a given type. Valid types are defined in
      # Google's Geocoding API documentation and include (among others):
      #
      #   :street_number
      #   :locality
      #   :neighborhood
      #   :route
      #   :postal_code
      #
      def address_components_of_type(type)
        address_components.select{ |c| c['types'].include?(type.to_s) }
      end

      def geometry
        @raw_result['geometry']
      end

      #%w(street_address route intersection political country administrative_area_level_1 administrative_area_level_2 administrative_area_level_3 colloquial_area locality sublocality neighborhood premise subpremise postal_code natural_feature airport park point_of_interest)
      def result_type
        types[0] if types
      end

      def location_type
        geometry['location_type'] if geometry
      end

      def location_type_as_int
        case(location_type)
        when "ROOFTOP"
          1.0
        when "APPROXIMATE"
          0.8
        when "RANGE_INTERPOLATED"
          0.7
        when "GEOMETRIC_CENTER"
          0.5
        else
          0.0
        end
      end

      def confidence
        # closest address component
        case
        when(!street_number.nil?)
          1.0
        when(!route.nil?)
          0.7
        when(!city.nil?)
          0.4
        when(!sub_state.nil?)
          0.2
        when(!state.nil?)
          0.1
        else
          0.0
        end
      end

      def latitude
        geometry["location"]["lat"] if geometry
      end

      def longitude
        geometry["location"]["lng"] if geometry
      end

      def accuracy
        # TODO: Fix this
        good_enough_types = %w(street_address postal_code subpremise premise intersection)
        return true if good_enough_types.include?(result_type)
        if (bounds = geometry['bounds'])
          if bounds['northeast'] and bounds['southwest']
            area =
              (bounds["southwest"]["lng"] - bounds["northeast"]["lng"]) *
              (bounds["southwest"]["lat"] - bounds["northeast"]["lat"])
            return true if area < 0.00004
          end
        end
        return false
      end

  end

end
