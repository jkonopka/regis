require 'regis/providers/base'
require 'regis/results/test'

module Regis::Provider
  class Test < Base

    def name
      "Test"
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

    private

    def results(query)
      Regis::Provider::Test.read_stub(query.text)
    end

  end
end