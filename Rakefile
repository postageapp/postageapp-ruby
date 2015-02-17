require 'bundler/setup'

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

namespace :travis do
  desc "Run tests across different environments, simulating Travis"
  task :test do
    require File.expand_path('test/travis_test', File.dirname(__FILE__))

    TravisTest.run!
  end

  desc "Report on which versions of Ruby are installed"
  task :versions do
    require File.expand_path('test/travis_test', File.dirname(__FILE__))

    TravisTest.validate_ruby_versions!
  end
end

task :default => :test
