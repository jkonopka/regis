require 'singleton'
require 'regis/configuration_hash'

module Regis

  def self.configure(options = nil, &block)
    if !options.nil?
      Configuration.instance.configure(options)
    end
  end

  def self.config
    Configuration.instance.data
  end

  def self.config_for_provider(provider_name)
    provider_name = provider_name.to_sym
    data = config.clone
    data.reject!{ |key,value| !Configuration::OPTIONS.include?(key.to_sym) }
    if config.has_key?(provider_name)
      data.merge!(config[provider_name])
      data.delete(provider_name)
    end
    data
  end

  class Configuration
    include Singleton
    OPTIONS = [
      :timeout,
      :provider,
      :ip_provider,
      :language,
      :http_headers,
      :use_https,
      :http_proxy,
      :https_proxy,
      :api_key,
      :app_id,
      :app_code,
      :units,
      :distances,
      :here
    ]

    attr_accessor :data

    def self.set_defaults
      instance.set_defaults
    end

    OPTIONS.each do |o|
      define_method o do
        @data[o]
      end
      define_method "#{o}=" do |value|
        @data[o] = value
      end
    end

    def configure(options)
      @data.rmerge!(options)
    end

    def initialize # :nodoc
      @data = Regis::ConfigurationHash.new
      set_defaults
    end

def set_defaults

      # geocoding options
      @data[:timeout]      = 3           # geocoding service timeout (secs)
      @data[:provider]       = :google     # name of street address geocoding service (symbol)
      @data[:ip_provider]    = :freegeoip  # name of IP address geocoding service (symbol)
      @data[:language]     = :en         # ISO-639 language code
      @data[:http_headers] = {}          # HTTP headers for lookup
      @data[:use_https]    = false       # use HTTPS for lookup requests? (if supported)
      @data[:http_proxy]   = nil         # HTTP proxy server (user:pass@host:port)
      @data[:https_proxy]  = nil         # HTTPS proxy server (user:pass@host:port)
      @data[:api_key]      = nil         # API key for geocoding service
      @data[:app_id]        = nil         # here app_id
      @data[:app_code]      = nil         # here app_code

      # calculation options
      @data[:units]     = :mi      # :mi or :km
      @data[:distances] = :linear  # :linear or :spherical
    end

    instance_eval(OPTIONS.map do |option|
      o = option.to_s
      <<-EOS
      def #{o}
        instance.data[:#{o}]
      end

      def #{o}=(value)
        instance.data[:#{o}] = value
      end
      EOS
    end.join("\n\n"))

  end
end
