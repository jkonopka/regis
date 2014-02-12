# encoding: utf-8

module Regis

  class Engines < Base

    get '/engines' do
      @engines = Supervisor.instance.engines
    end
    
  end

end