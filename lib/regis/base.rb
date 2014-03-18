module Regis

  ##
  # Search for information about an address or a set of coordinates.
  #
  def self.search(query, options = {})
    LOGGER.info "Geocoding #{query.inspect} (options #{options.inspect})"

    provider = Provider.get(options[:provider] || Configuration.provider)
    if provider.respond_to?(:rate_limit_per_day)
      rate_limit_per_day = provider.rate_limit_per_day
      if rate_limit_per_day
        current_rate = GeocodeLogEntry.
          where('created_at >= ?', Time.now - 24.hours).
          where('provider = ?', provider.name).count
        if current_rate >= rate_limit_per_day
          raise RateLimitedError.new(
            "Provider #{provider.name} has exceeded number of daily requests")
        end
      end
    end

    begin
      result = provider.search(query)
    rescue OverQueryLimitError => e
      LOGGER.info "Provider is over the query limit: #{e}"
      raise RateLimitedError.new(e.message)
    else
      Regis::GeocodeLogEntry.create!(
        query: query,
        result: result,
        provider: provider.name)
      result
    end
  end

  ##
  # Look up the coordinates of the given street or IP address.
  #
  def self.coordinates(address, options = {})
    if (results = search(address, options)).size > 0
      results.first.coordinates
    end
  end

  ##
  # Look up the address of the given coordinates ([lat,lon])
  # or IP address (string).
  #
  def self.address(query, options = {})
    if (results = search(query, options)).size > 0
      #Regis::GeocodeLogEntry.
      results.first.address
    end
  end

end