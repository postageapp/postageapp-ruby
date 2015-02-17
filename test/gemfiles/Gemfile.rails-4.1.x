source 'http://rubygems.org'

gem 'json'
gem 'rake'

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails', '~> 4.1.0'
  gem 'mocha'
end
