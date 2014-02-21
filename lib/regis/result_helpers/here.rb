module Regis::ResultHelper
  class Here

    attr_accessor :single_result

    def initialize(data)
      @single_result = data
    end

    ##
    # A string in the given format.
    #
    def address(format = :full)
      address_data['Label']
    end

    ##
    # A two-element array: [lat, lon].
    #
    def coordinates
      fail unless d = @single_result['Location']['DisplayPosition']
      [d['Latitude'].to_f, d['Longitude'].to_f]
    end

    def latitude
      @single_result['Location']['DisplayPosition']['Latitude'].to_f
    end

    def longitude
      @single_result['Location']['DisplayPosition']['Longitude'].to_f
    end

    def state
      address_data['County']
    end

    def province
      address_data['County']
    end

    def postal_code
      address_data['PostalCode']
    end

    def city
      address_data['City']
    end

    def state_code
      address_data['State']
    end

    def province_code
      address_data['State']
    end

    def country
      fail unless d = address_data['AdditionalData']
      if v = d.find{|ad| ad['key']=='CountryName'}
        return v['value']
      end
    end

    def country_code
      address_data['Country']
    end

    def county
      address_data['Country']
    end

    def street
      address_data['Street']
    end

    def street_number
      address_data['HouseNumber']
    end

    def location_type
      @single_result["MatchType"]
    end

    def location_type_as_int
      case(location_type)
      when "point"
        1.0
      when "line"
        0.7
      when "area"
        0.5
      else
        0.0
      end
    end

    def confidence
      # mix of location type and closest address component
      case(@single_result["MatchLevel"].downcase)
        when "housenumber"
          1.0
        when "street"
          0.7
        when "city"
          0.4
        when "county"
          0.2
        when "state"
          0.1
        else
          0.0
        end
    end

    def normalized_data
      { "location"=>{
          "lat"=>latitute,
          "lng"=>longitute,
          "location_type"=>location_type_as_int,
          "confidence" => confidence
        },
        "address" => {
        "formatted_address"=> address,
        "country"=>country_code,
        "state"=>state_code,
        "county"=>county,
        "city"=>city,
        "street"=> street,
        "house_number"=> street_number,
        "postal_code"=>postal_code
        }
      }
    end

    private # ----------------------------------------------------------------

    def address_data
      @single_result['Location']['Address'] || fail
    end

  end
end