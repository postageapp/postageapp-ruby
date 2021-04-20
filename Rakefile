# Avoid contaminating ENV with lots of BUNDLER_ variables
ENV_CLEAN = ENV.to_h

require 'bundler/setup'

ENV.replace(ENV_CLEAN)

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
