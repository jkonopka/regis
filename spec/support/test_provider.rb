require 'ostruct'

module Regis
  module Provider

    class Test < Base

      class Result
        KEYS = %w[
          latitude longitude neighborhood city state state_code sub_state
          sub_state_code province province_code postal_code country
          country_code address street_address street_number route geometry
        ]

        def initialize(attributes)
          @attributes = {}
          attributes.stringify_keys.each do |key, value|
            if KEYS.include?(key)
              @attributes[key] = value
            end
          end
        end

        def [](key)
          @attributes[key.to_s]
        end

        def as_json(*args)
          @attributes.as_json(*args)
        end
      end

      class Results
        def initialize(raw_results)
          @results = raw_results.map { |raw| Result.new(raw) }
        end

        def as_json(*args)
          @results.map { |r| r.as_json(*args) }
        end

        attr_reader :results
      end

      def search(query)
        raise NotImplementedError.new("This method must be stubbed")
      end

    end

  end
end