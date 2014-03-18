require_relative '../providers/ovi'

class Regis::Provider::Ovi

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

    attr_accessor :raw_result

    def initialize(data)
      @raw_result = data
    end

    def eql?(other)
      return other.is_a?(Result) &&
        @raw_result == other.raw_result
    end
    alias_method :==, :eql?

    def as_json(*args)
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
      fail unless d = @raw_result["results"][0]['properties']
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
      @raw_result['properties']['geoLatitude'].to_f
    end

    def longitute
      @raw_result['properties']['geoLongitude'].to_f
    end

    def location_type
      "unknown"
    end

    def formatted_address
#      "#{street_number} #{street}, #{city}, #{state} #{postal_code}, #{country}"
      f = []
      f << street_number if !street_number.nil?
      f << "#{street}," if !street.nil?
      f << "#{city}," if !city.nil?
      f << state if !state.nil?
      f << postal_code if !postal_code.nil?
      f << ", #{country}" if !country.nil?
      f.join(" ")
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
      @raw_result['properties'] || fail
    end

  end

end