require File.dirname(__FILE__) + '/helper'

class TestPostageApp < Test::Unit::TestCase
  
  def test_method_configure
    PostageApp.configure do |config|
      config.api_key  = 'abcdefg12345'
      config.hosts    = ['test.test']
    end
    assert_equal 'abcdefg12345',  PostageApp.configuration.api_key
    assert_equal %w( test.test ), PostageApp.configuration.hosts
  end
  
end