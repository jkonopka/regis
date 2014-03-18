# encoding: utf-8

module Regis

  class V1 < Sinatra::Base

    configure do
      enable :logging
      set :show_exceptions, false
      set :root, File.expand_path('..', __FILE__)
    end

    use Rack::ConditionalGet
    use Rack::PostBodyContentTypeParser
    use Rack::MethodOverride

    before do
      @configuration = Configuration.instance
    end

    before do
      cache_control :private, :no_store, :must_revalidate
    end

    helpers do
      def logger
        LOGGER
      end
    end

    error Sinatra::NotFound do |e|
      halt 404, 'Not found'
    end

  end

end