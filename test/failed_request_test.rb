require_relative './helper'

class FailedRequestTest < MiniTest::Test
  def setup
    super
  
    PostageApp.configuration.project_root = File.dirname(__FILE__)
  end
  
  def test_store_and_initialize
    assert_match(/.*?\/tmp\/postageapp_failed_requests/, PostageApp::FailedRequest.store_path)
    
    request = PostageApp::Request.new(:send_message, {
      headers: {
        'from' => 'sender@test.test',
        'subject' => 'Test Message'
      },
      recipients: 'test@test.test',
      content: {
        'text/plain' => 'text content',
        'text/html' => 'html content'
      }
    })

    assert PostageApp::FailedRequest.store(request)

    file_path = File.join(PostageApp::FailedRequest.store_path, request.uid)

    assert File.exist?(file_path)
    
    stored_request = PostageApp::FailedRequest.initialize_request(request.uid)

    assert stored_request.is_a?(PostageApp::Request)
    assert_equal request.url, stored_request.url
    assert_equal request.uid, stored_request.uid
    assert_equal request.arguments_to_send, stored_request.arguments_to_send
  end
  
  def test_initialize_request_when_not_found
    assert !PostageApp::FailedRequest.initialize_request('not_there')
  end
  
  def test_initialize_requests_with_bad_file
    file_path = File.join(PostageApp::FailedRequest.store_path, '1234567890')

    FileUtils.touch(file_path)

    assert !PostageApp::FailedRequest.initialize_request('1234567890')
  end
  
  def test_store_for_wrong_call_type
    request = PostageApp::Request.new(:get_project_info)

    assert !PostageApp::FailedRequest.store(request)
  end
  
  def test_store_with_no_file_path_defined
    PostageApp.configuration.project_root = nil

    assert !PostageApp::FailedRequest.store_path
    assert !PostageApp::FailedRequest.store('something')
  end
  
  def test_resend_all
    mock_failed_send
    
    request = PostageApp::Request.new(:send_message, {
      headers: {
        'from' => 'sender@test.test',
        'subject' => 'Test Message'
      },
      recipients: 'test@test.test',
      content: {
        'text/plain' => 'text content',
        'text/html' => 'html content'
      }
    })

    response = request.send
    assert response.fail?

    file_path = File.join(PostageApp::FailedRequest.store_path, request.uid)
    assert File.exist?(file_path)
    
    mock_successful_send
    
    request = PostageApp::Request.new(:get_project_info)
    
    message_receipt_response = stub(
      :fail? => false,
      :ok? => false,
      :not_found? => true
    )

    message_receipt_request = stub(:send => message_receipt_response)

    PostageApp::Request.stubs(:new).with do |a,b|
      a == :get_message_receipt
    end.returns(message_receipt_request)
    
    response = request.send

    assert response.ok?
    
    assert !File.exist?(file_path)
  end
  
  def test_resend_all_failure
    mock_failed_send
    request = PostageApp::Request.new(:send_message, {
      headers: {
        'from' => 'sender@test.test',
        'subject' => 'Test Message'
      },
      recipients: 'test@test.test',
      content: {
        'text/plain' => 'text content',
        'text/html' => 'html content'
      }
    })
    
    response = request.send

    assert response.fail?

    file_path = File.join(PostageApp::FailedRequest.store_path, request.uid)

    assert File.exist?(file_path)
    
    # Forcing to resend. Should quit right away as we can't connect
    PostageApp::FailedRequest.resend_all
    
    assert File.exist?(file_path)
  end
end
