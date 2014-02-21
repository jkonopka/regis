module Regis::ResultHelper
  class Ovi 

    attr_accessor :single_result

    def initialize(data)
      @single_result = data
    end

    ##
    # A string in the given format.
    #
    def address(format = :full)
      address_data['title']
    end

    ##
    # A two-element array: [lat, lon].
    #
    def coordinates
      fail unless d = @single_result["results"][0]['properties']
      [d['geoLatitude'].to_f, d['geoLongitude'].to_f]
    end

    def state
      address_data['addrStateCode']
    end

    def province
      address_data['addrCountyName']
    end

    def postal_code
      address_data['addrPostalCode']
    end

    def city
      address_data['addrCityName']
    end

    def state_code
      address_data['addrStateCode']
    end

    def province_code
      address_data['addrStateCode']
    end

    def country
      address_data['addrCountryName']
      #fail unless d = address_data['addrCountryName']
      # if v = d.find{|ad| ad['key']=='CountryName'}
      #   return v['value']
      # end
    end

    def country_code
      address_data['addrCountryCode']
    end

    def street
      address_data['addrStreetName']
    end

    def street_number
      address_data['addrHouseNumber']
    end

    def latitute
      @single_result['properties']['geoLatitude'].to_f
    end

    def longitute
      @single_result['properties']['geoLongitude'].to_f
    end

    def normalized_data
      { "location"=>{
        "lat"=>latitute,
        "lng"=>longitute,
        "location_type"=>confidence,
        "confidence" => confidence
        },
        "address" => {
        "formatted_address"=> formatted_address,
        "country"=>country_code,
        "state"=>state_code,
        "county"=>province,
        "city"=>city,
        "street"=> street,
        "house_number"=> street_number,
        "postal_code"=>postal_code
        }
      }
    end

    def location_type
      "unknown"
    end

    def confidence
      0.0
    end

    def formatted_address
#      "#{street_number} #{street}, #{city}, #{state} #{postal_code}, #{country}"
      f = []
      f << street_number if !street_number.nil?
      f << "#{street}," if !street.nil?
      f << "#{city}," if !city.nil?
      f << "#{state}," if !state.nil?
      f << state if !state.nil?
      f << postal_code if !postal_code.nil?
      f << ", #{country}" if !country.nil?

    end

    def confidence
      # mix of location type and closest address component
      case
        when(!street_number.nil?)
          1.0
        when(!street.nil?)
          0.7
        when(!city.nil?)
          0.4
        when(!province.nil?)
          0.2
        when(!state.nil?)
          0.1
        else
          0.0
        end
    end


    private # ----------------------------------------------------------------

    def address_data
      @single_result['properties'] || fail
    end


  end
end