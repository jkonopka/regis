require 'regis/providers/base'
require "regis/results/google"

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

    # def geocode(request)
    #   params = {
    #     'address' => request.address,
    #     'sensor' => 'false'
    #   }

    #   components = []
    #   if (country = request.constraints[:country])
    #     components.push("country:#{country}")
    #   end
    #   if (country = request.constraints[:state])
    #     components.push("administrative_area:#{state}")
    #   end
    #   if components.any?
    #     params['components'] = components.join('|')
    #   end

    #   case request.location_hint
    #     when Point
    #       # TODO
    #     when Bounds
    #       query_params['bounds'] = request.location_hint.northwest.map { |p|
    #         [p.latitude, p.longitude].join(',')
    #       }.join('|')
    #   end

    #   result = HTTP.get_json("http://maps.googleapis.com/maps/api/geocode/json",
    #     params: params)
    #   return normalize(result)
    # end

    private

    def valid_response?(response)
      status = parse_json(response.body)["status"]
      super(response) and ['OK', 'ZERO_RESULTS'].include?(status)
    end

    def results(query)
      if(Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ?", Time.now.utc.beginning_of_day]) >= rate_limit_per_day)
        raise_error(Regis::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
        return []
      end
      return [] unless doc = fetch_data(query)
      case doc['status']; when "OK" # OK status implies >0 results
        # increment query count here
        # 
        return doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Regis::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
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