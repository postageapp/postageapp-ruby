require 'bundler'
require 'rake/testtask'

Bundler.require

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

namespace :travis do
  task :test do
    require File.expand_path('test/travis_test', File.dirname(__FILE__))

    TravisTest.run!
  end
end
