require './config/environment'

require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

desc "Run specs"
task :spec do
  ENV['RACK_ENV'] = 'test'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = './spec/**/*_spec.rb'
  end
end
