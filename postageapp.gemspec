# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'postageapp/version'

Gem::Specification.new do |s|
  s.name = "postageapp"
  s.version = PostageApp::VERSION
  s.authors = [
    "Oleg Khabarov",
    "Scott Tadman",
    "The Working Group Inc."
  ]
  s.email = [
    "oleg@khabarov.ca",
    "tadman@postageapp.com"
  ]

  s.homepage = "http://github.com/postageapp/postageapp-ruby"

  s.summary = "Gem for communicating with the PostageApp email API"
  s.description = "Gem that interfaces with PostageApp service to send emails from Ruby applications"
  s.license = 'MIT'
  
  s.files = `git ls-files`.split("\n")
  s.platform = Gem::Platform::RUBY
  s.require_paths = [ 'lib' ]

  s.required_ruby_version = '>= 1.9.3'
  
  s.add_dependency 'json'
  s.add_dependency 'mail'
end
