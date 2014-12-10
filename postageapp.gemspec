# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'postageapp/version'

Gem::Specification.new do |s|
  s.name          = "postageapp"
  s.version       = PostageApp::VERSION
  s.authors       = ["Oleg Khabarov", "Scott Tadman", "The Working Group Inc."]
  s.email         = ["oleg@khabarov.ca", "scott@twg.ca"]
  s.homepage      = "http://github.com/postageapp/postageapp-ruby"
  s.summary       = "Easier way to send email from web apps"
  s.description   = "Gem that interfaces with PostageApp.com service to send emails from web apps"
  s.license       = 'MIT'
  
  s.files         = `git ls-files`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  
  s.add_dependency 'json'
end
