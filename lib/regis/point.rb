module Regis

  class Point

    attr_reader :lat, :lng

    def initialize(lat, lng)
      @lat, @lng = lat, lng
    end

    def self.parse(input)
      if input.is_a?(Array) and input.length == 2
        begin
          lat, lng = Float(input[0]), Float(input[1])
        rescue ArgumentError
          # Ignore
        else
          return Point.new(lat, lng)
        end
      elsif input.is_a?(Hash)
        begin
          lat, lng = Float(input['lat']), Float(input['lng'])
        rescue ArgumentError
          # Ignore
        else
          return Point.new(lat, lng)
        end
      end
    end

  end

end