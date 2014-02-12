module Regis

  class Bounds

    attr_reader :northwest, :southeast

    def initialize(nw, se)
      @northwest, @southeast = nw, se
    end

    def self.parse(input)
      if input.is_a?(Array) and input.length == 4
        nw = Point.parse(*input[0, 2])
        se = Point.parse(*input[2, 2])
        if nw and se
          return new(nw, se)
        end
      elsif input.is_a?(Hash)
        nw, se = Point.parse(input['nw']), Point.parse(input['se'])
        if nw and se
          return new(nw, se)
        end
      end
    end

  end

end