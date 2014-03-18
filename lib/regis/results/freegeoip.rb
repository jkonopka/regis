require_relative '../providers/freegeoip'

class Regis::Provider::Freegeoip

  class Results

    attr_reader :results
    attr_reader :raw_results

    def initialize(raw_results)
      @raw_results = raw_results
      @results = [Result.new(@raw_results)]
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

    def initialize(raw_result)
      @raw_result = raw_result
    end

    def as_json(*args)
      {}  # TODO
    end

    def address(format = :full)
      s = state_code.to_s == "" ? "" : ", #{state_code}"
      "#{city}#{s} #{postal_code}, #{country}".sub(/^[ ,]*/, "")
    end

    def city
      @raw_result['city']
    end

    def state
      @raw_result['region_name']
    end

    def state_code
      @raw_result['region_code']
    end

    def country
      @raw_result['country_name']
    end

    def country_code
      @raw_result['country_code']
    end

    def postal_code
      @raw_result['zipcode']
    end

    def self.response_attributes
      %w[metrocode ip]
    end

    response_attributes.each do |a|
      define_method a do
        @raw_result[a]
      end
    end
  end

end