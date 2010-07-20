require File.expand_path('../helper', __FILE__)

require 'postageapp/rails'

class RailsInitializationTest < Test::Unit::TestCase
  
  include ConstantDefinitions
  
  def test_something
    rails = Module.new do
      def self.logger
        'RAILS LOGGER'
      end
      def self.version
        '9.9.9'
      end
      def self.root
        'RAILS ROOT'
      end
    end
    define_constant('Rails', rails)
    PostageApp::Rails.initialize
    
    assert_equal 'RAILS LOGGER', PostageApp.configuration.logger
    assert_equal 'Rails v.9.9.9', PostageApp.configuration.framework
    assert_equal 'RAILS ROOT', PostageApp.configuration.project_root
  end
  
end