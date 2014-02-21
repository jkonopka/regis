module Regis::ResultHelper
  class Google
    attr_accessor :single_result

    def initialize(data)
      @single_result = data
    end

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
      @single_result['types']
    end

    def formatted_address
      @single_result['formatted_address']
    end

    def address_components
      @single_result['address_components']
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
      @single_result['geometry']
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
      # mix of location type and closest address component
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

    def normalized_data
      { "location"=>{
          "lat"=>latitude,
          "lng"=>longitude,
          "location_type"=>location_type_as_int,
          "confidence" => confidence
        },
        "address" => {
        "formatted_address"=> formatted_address,
        "country"=>country_code,
        "state"=>state_code,
        "county"=>sub_state_code,
        "city"=>city,
        "street"=> street_address,
        "house_number"=> street_number,
        "postal_code"=>postal_code
        }
      }
    end
  end
end