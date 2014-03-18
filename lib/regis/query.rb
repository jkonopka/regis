module Regis

  class Query

    attr_reader :text, :options

    def initialize(text, options = {})
      raise InvalidQueryError.new("Empty query") if text.blank?
      @text = text
      @options = options.dup.with_indifferent_access
    end

    def eql?(other)
      return other.is_a?(Query) &&
        @text == other.text &&
        @options == other.options
    end
    alias_method :==, :eql?

    def inspect
      "<Query text: #{@text.inspect} options: #{@options.inspect}>"
    end

    def as_json(*args)
      return {
        text: @text,
        options: @options
      }
    end

    def sanitized_text
      if coordinates?
        if text.is_a?(Array)
          text.join(',')
        else
          text.split(/\s*,\s*/).join(',')
        end
      else
        text
      end
    end

    def url
      @provider.query_url(self)
    end

    # Does the given string look like latitude/longitude coordinates?
    def coordinates?
      case @text
        when Array
          @text.length == 2 && @text.all? { |v| v.is_a?(Float) }
        when String
          !!text.to_s.strip.match(/\A-?[0-9\.]+, *-?[0-9\.]+\z/)
        else
          false
      end
    end

    # Return the latitude/longitude coordinates specified in the query,
    # or nil if none.
    def coordinates
      sanitized_text.split(',').map(&:to_f) if coordinates?
    end

    private

      def params_given?
        !!(options[:params].is_a?(Hash) and options[:params].keys.size > 0)
      end

  end

end
