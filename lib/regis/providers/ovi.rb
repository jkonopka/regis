require 'regis/providers/base'
require 'regis/results/ovi'

module Regis::Provider
  class Ovi < Base

    def name
      "Ovi"
    end

    def required_api_key_parts
      []
    end

    def query_url(query)
      "#{protocol}://lbs.ovi.com/search/6.2/#{if query.reverse_geocode? then 'reverse' end}geocode.json?" + url_query_string(query)
    end

    def rate_limit_per_day
      2500
    end

    def rate_limited
      if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ? and provider = ?", Time.now.utc.beginning_of_day, Regis::Configuration.provider.to_s]) >= rate_limit_per_day)
        raise_error(Regis::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
        @rate_limited = true
      else
        @rate_limited = false
      end
      @rate_limited

    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      return [] unless doc['Response'] && doc['Response']['View']
      if r=doc['Response']['View']
        return [] if r.nil? || !r.is_a?(Array) || r.empty?
        return r.first['Result']
      end
      []
    end

    def query_url_params(query)
      options = {
        :gen=>1,
        :app_id=>api_key,
        :app_code=>api_code
      }

      if query.reverse_geocode?
        super.merge(options).merge(
          :prox=>query.sanitized_text,
          :mode=>:retrieveAddresses
        )
      else
        super.merge(options).merge(
          :searchtext=>query.sanitized_text
        )
      end
    end

    def api_key
      if a=configuration.api_key
        return a.first if a.is_a?(Array)
      end
    end

    def api_code
      if a=configuration.api_key
        return a.last if a.is_a?(Array)
      end
    end
  end
end
