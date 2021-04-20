# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('./lib', __dir__))

Gem::Specification.new do |s|
  s.name = 'postageapp'
  s.version = File.read(File.expand_path('VERSION', __dir__)).gsub(/\s/, '')
  s.authors = [
    'Scott Tadman',
    'Oleg Khabarov',
    'PostageApp Ltd.'
  ]
  s.email = [
    'tadman@postageapp.com',
    'oleg@khabarov.ca',
    'info@postageapp.com'
  ]

  s.homepage = 'http://github.com/postageapp/postageapp-ruby'

  s.summary = 'Client library for PostageApp Email API'
  s.description = 'PostageApp Library for Ruby and Ruby on Rails applications'
  s.license = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.platform = Gem::Platform::RUBY
  s.require_paths = [ 'lib' ]

  s.required_ruby_version = '>= 2.5.0'

  s.add_dependency 'mail', '~> 2.4'
end
