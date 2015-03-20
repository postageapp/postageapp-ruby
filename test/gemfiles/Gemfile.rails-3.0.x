source 'http://rubygems.org'

gem 'json'
gem 'rake'
gem 'mail'

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails', '~> 3.0.0'
  gem 'mocha'
end
