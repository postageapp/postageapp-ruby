require File.expand_path('../helper', __FILE__)
require File.expand_path('../mailer/notifier', __FILE__)

require 'action_mailer'

class MailerTest < Test::Unit::TestCase
  
  def test_create_blank
    assert request = TestNotifier.create_blank
    assert_equal :send_message, request.api_method
    assert_equal 'http://api.postageapp.local/v.1.0/send_message.json', request.call_url
    assert request.arguments.blank?
  end
  
  def test_create_with_no_content
    assert request = TestNotifier.create_with_no_content
    assert_equal 'test@test.test', request.arguments[:recipients]
    assert_equal ({:from=>"text@test.test", :subject=>"Test Email"}), request.arguments[:headers]
    assert request.arguments[:content].blank?
  end
  
  def test_create_with_text_only_view
    assert request = TestNotifier.create_with_text_only_view
    assert_equal 'text only: plain text', request.arguments[:content]['text/plain']
  end
  
  def test_create_with_html_and_text_views
    assert request = TestNotifier.create_with_html_and_text_views
    assert_equal 'html and text: plain text', request.arguments[:content]['text/plain']
    assert_equal 'html and text: html', request.arguments[:content]['text/html']
  end
  
  # def test_deliver_with_html_and_text_views
  #   assert response = TestNotifier.deliver_with_html_and_text_views
  #   assert response.is_a?(Postage::Response)
  #   assert response.success?
  # end
  
  def test_create_with_simple_view
    assert request = TestNotifier.create_with_simple_view
    assert_equal 'simple view content', request.arguments[:content]['text/plain']
  end
  
  def test_create_with_manual_parts
    assert request = TestNotifier.create_with_manual_parts
    assert_equal 'text content', request.arguments[:content]['text/plain']
    assert_equal 'html content', request.arguments[:content]['text/html']
    assert !request.arguments[:attachments].blank?
    assert !request.arguments[:attachments]['foo.jpg'][:content].blank?
    assert_equal 'image/jpeg', request.arguments[:attachments]['foo.jpg'][:content_type]
  end
  
  def test_create_with_body_and_attachment
    assert request = TestNotifier.create_with_body_and_attachment
    assert !request.arguments[:content].blank?
    assert !request.arguments[:content]['text/plain'].blank?
    assert_equal 'body text', request.arguments[:content]['text/plain']
    assert !request.arguments[:attachments].blank?
    assert !request.arguments[:attachments]['foo.jpg'][:content].blank?
    assert_equal 'image/jpeg', request.arguments[:attachments]['foo.jpg'][:content_type]
  end

  def test_create_with_custom_postage_variables
    assert request = TestNotifier.create_with_custom_postage_variables
    assert_equal 'test_template', request.arguments[:template]
    assert_equal ({:variable => 'value'}), request.arguments[:variables]
  end
  
  # def test_create_with_recipient_override
  #   Postage.recipient_override = 'oleg@test.test'
  #   assert request = TestNotifier.create_blank
  #   assert_equal 'oleg@test.test', request.arguments[:recipient_override]
  # end
  
end