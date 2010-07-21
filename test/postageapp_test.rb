require File.expand_path('../helper', __FILE__)

class PostageAppTest < Test::Unit::TestCase
  
  def test_method_configure
    PostageApp.configure do |config|
      config.api_key  = 'abcdefg12345'
      config.host     = 'test.test'
    end
    assert_equal 'abcdefg12345',  PostageApp.configuration.api_key
    assert_equal 'test.test',     PostageApp.configuration.host
  end
  
  def test_logger
    assert PostageApp.logger.is_a?(Logger)
  end
  
end