source 'http://rubygems.org'

gem 'json'
gem 'mail'
gem 'bundler', '~> 1.0.0'
gem 'mime-types', '2.99.1' # Locked for 1.9 compatibility

group :test do
  gem 'rake'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails', '~> 3.0.0'
  gem 'mocha'
end
