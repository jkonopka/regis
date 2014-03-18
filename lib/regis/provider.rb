module Regis
  module Provider

    def self.get(name)
      if ALL_SERVICES.include?(name.to_s.downcase.to_sym)
        klass = Regis::Provider.const_get(name.to_s.classify)
      else
        klass = nil
      end
      unless klass.superclass == Regis::Provider::Base
        raise ArgumentError, "Unknown provider #{name.inspect}"
      end
      klass.new
    end

    private

      ALL_SERVICES = [
        :google,
        :test,
        :ovi,
        :here
      ].freeze


  end
end