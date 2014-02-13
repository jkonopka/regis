require "bundler"
Bundler.require

ENV['RACK_ENV'] ||= "development"
environment = ENV['RACK_ENV']

unless defined?(LOGGER)
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::INFO
end

$LOAD_PATH.unshift(File.expand_path('../../api', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'sinatra'
require 'sinatra/reloader'

#require 'application'
require 'v1'

%w(
  lib
  api
).each do |path|
  Dir.glob(File.expand_path("../../#{path}/**/*.rb", __FILE__)).each do |f|
    require f
  end
end

# Dir.glob(File.expand_path('../../lib/**/*.rb', __FILE__)).each do |file_name|
#   require file_name
# end

# Dir.glob(File.expand_path('../../lib/*.rb', __FILE__)).each do |file_name|
#   require file_name
# end

Rabl.configure do |config|
  config.include_json_root = false
end

#Regis::Configuration.instance.load!
