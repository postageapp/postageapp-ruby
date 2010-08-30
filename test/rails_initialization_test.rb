require File.expand_path('../helper', __FILE__)

require File.expand_path('../../lib/postageapp/rails/rails', __FILE__)

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
      def self.env
        "RAILS ENV"
      end
    end
    define_constant('Rails', rails)
    PostageApp::Rails.initialize
    
    assert_equal 'Rails 9.9.9', PostageApp.configuration.framework
    assert_equal 'RAILS ROOT', PostageApp.configuration.project_root
    assert_equal 'RAILS ENV', PostageApp.configuration.environment
  end
  
end