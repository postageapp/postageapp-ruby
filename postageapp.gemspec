# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'postageapp/version'

Gem::Specification.new do |s|
  s.name = 'postageapp'
  s.version = PostageApp::VERSION
  s.authors = [
    'Scott Tadman',
    'Oleg Khabarov',
    'The Working Group Inc.'
  ]
  s.email = [
    'tadman@postageapp.com',
    'oleg@khabarov.ca'
  ]

  s.homepage = 'http://github.com/postageapp/postageapp-ruby'

  s.summary = 'Client library for PostageApp Email API'
  s.description = 'PostageApp Library for Ruby and Ruby on Rails applications'
  s.license = 'MIT'
  
  s.files = `git ls-files`.split("\n")
  s.platform = Gem::Platform::RUBY
  s.require_paths = [ 'lib' ]

  s.required_ruby_version = '>= 1.9.3'
  
  s.add_dependency 'json', '>= 1.8'
  s.add_dependency 'mail', '~> 2.4'
end
