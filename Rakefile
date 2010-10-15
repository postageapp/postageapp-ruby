require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'postageapp'
    gem.summary     = 'Easier way to send email from web apps'
    gem.description = 'Gem that interfaces with PostageApp.com service to send emails from web apps'
    gem.email       = 'oleg@twg.ca'
    gem.homepage    = 'http://github.com/theworkinggroup/postageapp-gem'
    gem.authors     = ['Oleg Khabarov, The Working Group Inc']
    
    gem.add_dependency 'json', '>=1.4.6'
    gem.add_development_dependency 'mocha', '>= 0.9.8'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort 'RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov'
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "postageapp #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
