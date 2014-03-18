ENV['RACK_ENV'] ||= 'test'
Bundler.require(:test)

# Simplecov must be loaded before everything else
require 'simplecov'
SimpleCov.add_filter 'spec'
SimpleCov.add_filter 'config'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)

require 'rspec'
require 'rspec/autorun'
require 'rack/test'
require 'excon'
require 'webmock/rspec'
require 'stringio'
require 'pp'

require_relative './support/test_provider'
require_relative './support/shared_examples'

set :environment, :test

LOGGER.level = Logger::FATAL

RSpec.configure do |config|
  config.before :each do
    WebMock.reset!
  end
  config.around :each do |example|
    clear_cookies if respond_to?(:clear_cookies)
    ActiveRecord::Base.connection.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
  config.alias_it_should_behave_like_to :it_implements, 'implements:'
end
