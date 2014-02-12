require File.expand_path('../config/environment', __FILE__)

set :environment, ENV['RACK_ENV'].to_sym

map '/api/regis/v1' do
  run Regis::Api::V1
end
