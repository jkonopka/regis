module Regis

  class GeocodeLogEntry < ActiveRecord::Base

    serialize :result, JSON
    serialize :query, JSON

  end

end
