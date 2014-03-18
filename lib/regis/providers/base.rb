module Regis
  module Provider

    class Base

      # Human-readable name of the geocoding API.
      def name
        self.class.name.gsub(/^.*::(.*)$/, '\1').underscore
      end

      # Array containing string descriptions of keys required by the API.
      # Empty array if keys are optional or not required.
      def required_api_key_parts
        []
      end

      # URL to use for querying the geocoding engine.
      def query_url(query)
        raise NotImplementedError
      end

      private # -------------------------------------------------------------

      ##
      # An object with configuration data for this particular lookup.
      #
      def configuration
        Regis.config_for_provider(name)
      end

      ##
      # Object used to make HTTP requests.
      #
      def http_client
        protocol = "http#{'s' if configuration.use_https}"
        proxy_name = "#{protocol}_proxy"
        if proxy = configuration.send(proxy_name)
          proxy_url = !!(proxy =~ /^#{protocol}/) ? proxy : protocol + '://' + proxy
          begin
            uri = URI.parse(proxy_url)
          rescue URI::InvalidURIError
            raise ConfigurationError,
              "Error parsing #{protocol.upcase} proxy URL: '#{proxy_url}'"
          end
          Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
        else
          Net::HTTP
        end
      end

      ##
      # Geocoder::Result object or nil on timeout or other error.
      #
      def results(query)
        raise NotImplementedError
      end

      def query_url_params(query)
        query.options[:params] || {}
      end

      def url_query_string(query)
        hash_to_query(
          query_url_params(query).reject{ |key,value| value.nil? }
        )
      end

      ##
      # Returns a parsed search result (Ruby hash).
      #
      def fetch_data(query)
        parse_raw_data fetch_raw_data(query)
      rescue SocketError => e
        raise ConnectionError.new(e.message)
      end

      def parse_json(data)
        if defined?(ActiveSupport::JSON)
          ActiveSupport::JSON.decode(data)
        else
          JSON.parse(data)
        end
      end

      ##
      # Parses a raw search result (returns hash or array).
      #
      def parse_raw_data(raw_data)
        parse_json(raw_data)
      end

      ##
      # Protocol to use for communication with geocoding services.
      # Set in configuration but not available for every service.
      #
      def protocol
        "http" + (configuration.use_https ? "s" : "")
      end

      def valid_response?(response)
        (200..399).include?(response.code.to_i)
      end

      ##
      # Fetch a raw geocoding result (JSON string).
      #
      def fetch_raw_data(query)
        check_api_key_configuration!(query)
        response = make_api_request(query)
        response.body
      end

      ##
      # Make an HTTP(S) request to a geocoding API and
      # return the response object.
      #
      def make_api_request(query)
        Timeout.timeout(configuration.timeout) do
          uri = URI.parse(query_url(query))
          args = [uri.host, uri.port]
          args = args.push(uri.user, uri.password) unless uri.user.nil? or uri.password.nil?
          opts = {}
          opts[:use_ssl] = true if configuration.use_https

          http_client.start(*args, opts) do |client|
            client.get(uri.request_uri, configuration.http_headers)
          end
        end
      end

      def check_api_key_configuration!(query)
        key_parts = required_api_key_parts
        if key_parts.present? and key_parts.size > Array(configuration.api_key).size
          parts_string = key_parts.size == 1 ? key_parts.first : key_parts
          raise Regis::ConfigurationError,
            "The #{query.provider.name} API requires a key to be configured: " +
            parts_string.inspect
        end
      end

      ##
      # Simulate ActiveSupport's Object#to_query.
      # Removes any keys with nil value.
      #
      def hash_to_query(hash)
        require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
        hash.collect{ |p|
          p[1].nil? ? nil : p.map{ |i| CGI.escape i.to_s } * '='
        }.compact.sort * '&'
      end

    end
  end
end
