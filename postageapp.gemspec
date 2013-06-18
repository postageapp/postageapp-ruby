# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'postageapp/version'

Gem::Specification.new do |s|
  s.name          = "postageapp"
  s.version       = PostageApp::VERSION
  s.authors       = ["Oleg Khabarov", "The Working Group Inc"]
  s.email         = ["oleg@khabarov.ca"]
  s.homepage      = "http://github.com/twg/api_docs"
  s.summary       = "Easier way to send email from web apps"
  s.description   = "Gem that interfaces with PostageApp.com service to send emails from web apps"
  
  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  
  s.add_dependency 'json'
end