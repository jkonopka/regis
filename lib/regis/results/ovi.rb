require 'regis/results/base'

module Regis::Result
  class Ovi < Base

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
      fail unless d = @data["results"][0]['properties']
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

    def latitute
      @data["results"][0]['properties']['geoLatitude'].to_f
    end

    def longitute
      @data["results"][0]['properties']['geoLatitude'].to_f
    end

    def normalized_data
      { "location"=>{
        "lat"=>latitute,
        "lng"=>longitute,
        "location_type"=>location_type,
        "confidence" => confidence
        },
        "address" => {
        "formatted_address"=> formatted_address,
        "country"=>country_code,
        "state"=>state_code,
        "county"=>province,
        "city"=>city,
        "street"=> street,
        "house_number"=> house_number,
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
      "3 Paulmier Pl, Jersey City, NJ 07302, United States"
    end

    
    private # ----------------------------------------------------------------

    def address_data
      @data["results"][0]['properties'] || fail
    end
  end
end
