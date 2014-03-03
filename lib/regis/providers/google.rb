require 'regis/providers/base'
require "regis/results/google"
require 'regis/result_helpers/google'

module Regis::Provider

  class Google < Base

    def name
      "Google"
    end

    def query_url(query)
      "#{protocol}://maps.googleapis.com/maps/api/geocode/json?" + url_query_string(query)
    end

    def rate_limit_per_day
      2500
    end

    def rate_limited
      if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ? and provider = ?", Time.now.utc-24.hours, name.downcase]) >= rate_limit_per_day)
        raise_error(Regis::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
        @rate_limited = true
#      else
#        @rate_limited = false  # uncomment this to override rate_limited
      end
      @rate_limited

    end
    private

    def valid_response?(response)
      status = parse_json(response.body)["status"]
      super(response) and ['OK', 'ZERO_RESULTS'].include?(status)
    end

    def results(query)
      return [] unless doc = fetch_data(query)
      case doc['status']; when "OK" # OK status implies >0 results
        return doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Regis::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
          @rate_limited = true
      when "REQUEST_DENIED"
        raise_error(Regis::RequestDenied) ||
          warn("Google Geocoding API error: request denied.")
      when "INVALID_REQUEST"
        raise_error(Regis::InvalidRequest) ||
          warn("Google Geocoding API error: invalid request.")
      end
      return []
    end

    def query_url_google_params(query)
      params = {
        (query.reverse_geocode? ? :latlng : :address) => query.sanitized_text,
        :sensor => "false",
        :language => configuration.language
      }
      unless (bounds = query.options[:bounds]).nil?
        params[:bounds] = bounds.map{ |point| "%f,%f" % point }.join('|')
      end
      unless (region = query.options[:region]).nil?
        params[:region] = region
      end
      unless (components = query.options[:components]).nil?
        params[:components] = components.is_a?(Array) ? components.join("|") : components
      end
      params
    end

    def query_url_params(query)
      query_url_google_params(query).merge(
        :key => configuration.api_key
      ).merge(super)
    end

  end

end