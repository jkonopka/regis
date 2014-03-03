require 'regis/providers/base'
require 'regis/results/ovi'
require 'regis/result_helpers/ovi'

module Regis::Provider
  class Ovi < Base

    def name
      "Ovi"
    end

    def required_api_key_parts
      []
    end

    def query_url(query)
#      "#{protocol}://lbs.ovi.com/search/6.2/#{if query.reverse_geocode? then 'reverse' end}geocode.json?" + url_query_string(query)
#      "#{protocol}://where.desktop.mos.svc.ovi.com/json?dv=OviMapsAPI&la=en-US&q=3+Paulmier+Place%2C+07302&to=20&vi=where&lat=0&lon=0"
      "#{protocol}://where.desktop.mos.svc.ovi.com/json?" + url_query_string(query)
    end

    def rate_limit_per_day
      50000
    end

    # ha! this is wrong... configuration is not current
    def rate_limited
      if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ? and provider = ?", Time.now.utc-24.hours, name.downcase]) >= rate_limit_per_day)
        raise_error(Regis::OverQueryLimitError) ||
          warn("OVI Geocoding API error: over query limit.")
        @rate_limited = true
      else
        @rate_limited = false
      end
      @rate_limited

    end

    private # ---------------------------------------------------------------

    def results(query)
      return [] unless doc = fetch_data(query)
      return [] unless doc['results']
      # if r=doc['Response']['View']
      #   return [] if r.nil? || !r.is_a?(Array) || r.empty?
      #   return r.first['Result']
      # end
      # []
      return doc['results']
    end

    def query_url_params(query)
      options = {
        :dv=>"OviMapsAPI",
        :la=>"en-US",
        :vi=>"where",
        :lat=>0,
        :lon=>0,
      }

      if query.reverse_geocode?
        super.merge(options).merge(
          :prox=>query.sanitized_text,
          :mode=>:retrieveAddresses
        )
      else
        super.merge(options).merge(
          :q=>query.sanitized_text
        )
      end
    end

  end
end
