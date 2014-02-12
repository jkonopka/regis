# encoding: utf-8

module Regis

  class Base < Sinatra::Base

    configure do |config|
      config.set :logging, true
      config.set :show_exceptions, false
      config.set :root, File.expand_path('..', __FILE__)
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

    error StandardError, Exception do |e|
      LOGGER.error "Uncaught exception while processing #{request.url}: #{e.class}: #{e}\n" +
        e.backtrace.map { |s| "\t#{s}\n" }.join
      if ENV['RACK_ENV'] == 'production'
        halt 500, "Internal error"
      else
        halt 500, e.message
      end
    end

  end

end