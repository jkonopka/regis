require "bundler"
Bundler.require

ENV['RACK_ENV'] ||= "development"
environment = ENV['RACK_ENV']

unless defined?(LOGGER)
  LOGGER = SyslogLogger('regis')
  LOGGER.level = Logger::INFO
end

%w(
  lib/regis
  app/regis
).each do |path|
  Dir.glob(File.expand_path("../../#{path}/**/*.rb", __FILE__)).each do |f|
    require f
  end
end

Regis::Configuration.instance.load!
