source 'http://rubygems.org'

gem 'json', '~> 1.8.3'
gem 'mail'
gem 'mime-types', '2.99.1' # Locked for 1.9 compatibility

group :test do
  gem 'rake'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'mocha'
end
