source 'https://rubygems.org/'

gem 'rake'
gem 'activerecord'
gem 'sinatra', '~> 1.4'
gem 'sinatra-reloader'
gem 'sinatra-activerecord'

gem 'rack', '~> 1.4'
gem 'rack-contrib', '~> 1.1.0', :require => 'rack/contrib'
gem 'rabl', '~> 0.7.0'
gem 'excon', '~> 0.12.0'
gem 'unicorn', '~> 4.3.1'
gem 'activesupport', '~> 3.2.0'
gem 'json', '~> 1.8'
gem 'pg'

group :development, :test do
  gem 'bengler_test_helper', git: 'https://github.com/bengler/bengler_test_helper.git', require: false
end

group :test do
  gem 'rspec', '~> 2.8'
  gem 'simplecov', :require => false
  gem 'webmock'
  gem 'rack-test'
end
