require "regis/configuration"
require "regis/query"
#require "geocoder/calculations"
require "regis/exceptions"
#require "geocoder/cache"
require "regis/request"
require "regis/provider"
require "regis/ip_address"
#require "geocoder/models/active_record" if defined?(::ActiveRecord)
#require "geocoder/models/mongoid" if defined?(::Mongoid)
#require "geocoder/models/mongo_mapper" if defined?(::MongoMapper)

module Regis
  extend self

  ##
  # Search for information about an address or a set of coordinates.
  #
  def search(query, options = {})
    ##Regis::GeocodeLogEntries.count(:all, :conditions => ["created_at >= ?", Time.now.utc.beginning_of_day])
    query = Regis::Query.new(query, options) unless query.is_a?(Regis::Query)
    result = (query.blank? ? [] : query.execute)
    if(!result.empty?)
      Regis::GeocodeLogEntries.create!(:query => query, :result => result, :provider => Regis::Configuration.provider.to_s)
    end
    result
  end

  ##
  # Look up the coordinates of the given street or IP address.
  #
  def coordinates(address, options = {})
    if (results = search(address, options)).size > 0
      results.first.coordinates
    end
  end

  ##
  # Look up the address of the given coordinates ([lat,lon])
  # or IP address (string).
  #
  def address(query, options = {})
    if (results = search(query, options)).size > 0
      GeocodeLogEntries.
      results.first.address
    end
  end
end
