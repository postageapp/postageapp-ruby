require File.expand_path('../helper', __FILE__)

class RequestTest < Test::Unit::TestCase
  
  def test_method_uid
    request = PostageApp::Request.new(:test_method)
    uid = request.uid
    assert_match /\w{32}/, uid
    assert_equal uid, request.uid
    assert_not_equal uid, request.uid(true)
  end
  
  def test_method_url
    request = PostageApp::Request.new(:test_method)
    assert_equal 'api.postageapp.local',    request.url.host
    assert_equal 80,                        request.url.port
    assert_equal '/v.1.0/test_method.json', request.url.path
  end
  
  def test_method_arguments_to_send
    request = PostageApp::Request.new(:test_method)
    args = request.arguments_to_send
    assert_equal '1234567890abcdef', args[:api_key]
    assert_match /\w{32}/, args[:uid]
    
    request.arguments = { :data => 'content' }
    args = request.arguments_to_send
    assert_equal '1234567890abcdef', args[:api_key]
    assert_match /\w{32}/, args[:uid]
    assert_equal 'content', args[:arguments][:data]
  end
  
  def test_send
    flunk
  end
  
  def test_send_failure
    flunk
  end
  
end