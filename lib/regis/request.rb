module Regis

  class Request

    attr_reader :address
    attr_reader :constraints

    def initialize(address, options = {})
      @address = address
      @constraints = (options[:constraints] || {}).with_indifferent_access
      if (hint = options[:location_hint]) and hint.is_a?(Hash)
        hint = hint.with_indifferent_access
        if hint[:point]
          @location_hint = Point.parse(hint[:point])
        elsif hint[:bounds]
          @location_hint = Bounds.parse(hint[:bounds])
        end
      end
    end

  end

end