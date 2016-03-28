source 'http://rubygems.org'

# rubygems 1.8.30

gem 'bundler', '1.0.22'
gem 'rails', '~> 3.0.0'

gem 'json'
gem 'mail'
gem 'mime-types', '~> 1.16' # Rails 3.0.x dependency

group :test do
  gem 'rake'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'mocha'
end
