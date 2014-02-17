require 'regis/providers/base'
require 'regis/results/test'

module Regis::Provider
  class Test < Base

    def name
      "Test"
    end

    def rate_limit_per_day
      5
    end

    def self.add_stub(query_text, results)
      stubs[query_text] = results
    end

    def self.set_default_stub(results)
      @default_stub = results
    end

    def self.read_stub(query_text)
      stubs.fetch(query_text) {
        return @default_stub unless @default_stub.nil?
        raise ArgumentError, "unknown stub request #{query_text}"
      }
    end

    def self.stubs
      @stubs ||= {}
    end

    def self.reset
      @stubs = {}
      @default_stub = nil
    end

    def rate_limited
      if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ? and provider = ?", Time.now.utc.beginning_of_day, Regis::Configuration.provider.to_s]) >= rate_limit_per_day)
        raise_error(Regis::OverQueryLimitError) ||
          warn("Test Geocoding API error: over query limit.")
        @rate_limited = true
      else
        @rate_limited = false
      end
      @rate_limited

    end

    private

    def results(query)
      # if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ? and provider = ?", Time.now.utc.beginning_of_day, Regis::Configuration.provider.to_s]) >= rate_limit_per_day)
      #   raise_error(Regis::OverQueryLimitError) ||
      #     warn("Google Geocoding API error: over query limit.")
      #   return []
      # end

      Regis::Provider::Test.read_stub(query.text)
    end

  end

  Regis::Provider::Test.set_default_stub(
    [
      {
        'latitude'     => 40.7143528,
        'longitude'    => -74.0059731,
        'address'      => 'New York, NY, USA',
        'state'        => 'New York',
        'state_code'   => 'NY',
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ]
  )

end