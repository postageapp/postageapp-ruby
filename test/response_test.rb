require File.expand_path('../helper', __FILE__)

class ResponseTest < Test::Unit::TestCase
  
  def test_initialization
    object = stub(:body => {
      'response' => {
        'uid'     => 'md5_hash_uid',
        'status'  => 'ok',
        'message' => 'api reply message'
      },
      'data' => {
        'key' => 'value'
      }
    }.to_json)
    
    response = PostageApp::Response.new(object)
    assert_equal 'md5_hash_uid',        response.uid
    assert_equal 'ok',                  response.status
    assert_equal 'api reply message',   response.message
    assert_equal ({'key' => 'value'}),  response.data
    assert response.ok?
  end
  
  def test_status_check
    response = PostageApp::Response.new(nil)
    assert_equal 'fail', response.status
    assert response.fail?
    assert !response.ok?
    assert !response.really?
    
    begin
      response.bad_method 
      assert false
    rescue NoMethodError 
      assert true
    end
  end
  
end