require 'regis'

module Regis
  module Request

    def location
      @location ||= begin
        detected_ip = env['HTTP_X_REAL_IP'] || (
          env['HTTP_X_FORWARDED_FOR'] &&
          env['HTTP_X_FORWARDED_FOR'].split(",").first.strip
        )
        detected_ip = IpAddress.new(detected_ip.to_s)
        if detected_ip.valid? and !detected_ip.loopback?
          real_ip = detected_ip.to_s
        else
          real_ip = self.ip
        end
        Regis.search(real_ip).first
      end
      @location
    end
  end
end

if defined?(Rack) and defined?(Rack::Request)
  Rack::Request.send :include, Regis::Request
end
