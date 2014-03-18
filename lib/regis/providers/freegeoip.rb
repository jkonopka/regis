module Regis::Provider
  class Freegeoip < Base

    def query_url(query)
      "#{protocol}://#{host}/json/#{query.sanitized_text}"
    end

    def search(query)
      # note: Freegeoip.net returns plain text "Not Found" on bad request
      doc = fetch_data(query)
      if doc.is_a?(String)
        doc = nil
      end
      Results.new(doc || {})
    end

    private # ---------------------------------------------------------------

    def parse_raw_data(raw_data)
      raw_data.match(/^<html><title>404/) ? nil : super(raw_data)
    end

    def host
      configuration[:host] || "freegeoip.net"
    end

  end
end