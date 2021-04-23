# Avoid contaminating ENV with lots of BUNDLER_ variables
# require 'bundler/setup'

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

namespace :travis do
  desc "Run tests across different environments, simulating Travis"
  task :test do
    require_relative './test/travis_test'

    TravisTest.run!
  end

  desc "Report on which versions of Ruby are installed"
  task :versions do
    require_relative './test/travis_test'

    TravisTest.validate_ruby_versions!
  end
end

task default: :test

namespace :test do
  task :rails do
    ENV['BUNDLE_GEMFILE'] = File.expand_path('./test/gemfiles/Gemfile.rails-6.1.x', __dir__)

    require 'bundler/setup'

    p Rails
  end
end
