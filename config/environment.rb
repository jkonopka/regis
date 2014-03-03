load(File.expand_path('../site.rb', __FILE__)) if File.exist?(File.expand_path('../site.rb', __FILE__))

require "bundler"
Bundler.require

require 'sinatra'
require 'sinatra/reloader'
require 'yaml'
require 'active_record'

$LOAD_PATH.unshift(File.expand_path('../../api', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

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

ENV['RACK_ENV'] ||= "development"
environment = ENV['RACK_ENV']

unless defined?(LOGGER)
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::INFO
end

Rabl.configure do |config|
  config.include_json_root = false
end

ActiveRecord::Base.logger ||= LOGGER

ActiveRecord::Base.configurations = YAML.load(
  ERB.new(File.read(File.expand_path("../database.yml", __FILE__))).result).with_indifferent_access

ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[environment])
