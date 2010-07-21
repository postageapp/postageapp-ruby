require File.expand_path('../helper', __FILE__)

require 'postageapp/rails'

class RailsInitializationTest < Test::Unit::TestCase
  
  include ConstantDefinitions
  
  def test_initialization
    rails = Module.new do
      def self.version
        '9.9.9'
      end
      def self.root
        'RAILS ROOT'
      end
    end
    define_constant('Rails', rails)
    PostageApp::Rails.initialize
    
    assert_equal 'Rails 9.9.9', PostageApp.configuration.framework
    assert_equal 'RAILS ROOT', PostageApp.configuration.project_root
  end
  
end