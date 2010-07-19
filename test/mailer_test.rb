# Mailer Test
# This test will test integration with either ActionMailer 2.* or 3.*
# depending what you have installed

require File.expand_path('../helper', __FILE__)


class MailerTest < Test::Unit::TestCase
  
  # tests for ActionMailer bundled with Rails 3
  if ActionMailer::VERSION::MAJOR >= 3
    require File.expand_path('../mailer/action_mailer_3/notifier', __FILE__)
    
    def test_create_blank
      mail = Notifier.blank
    end
    
    def test_with_simple_view
      mail = Notifier.with_simple_view
      raise mail.inspect
    end
    
    def test_with_text_only_view
      mail = Notifier.with_text_only_view
      raise mail.arguments['content'].to_yaml
    end
    
    def test_with_html_and_text_views
      mail = Notifier.with_html_and_text_views
      raise mail.inspect
    end
    
    
  # tests for ActionMailer bundled with Rails 2
  else
    require File.expand_path('../mailer/action_mailer_2/notifier', __FILE__)
    
    def test_create_blank
      assert request = Notifier.create_blank
      assert_equal :send_message, request.method
      assert_equal 'https://api.postageapp.com/v.1.0/send_message.json', request.url.to_s
      assert request.arguments.blank?
    end
    
    def test_create_with_no_content
      assert request = Notifier.create_with_no_content
      assert_equal 'test@test.test', request.arguments['recipients']
      assert_equal ({ 'from' => 'text@test.test', 'subject' => 'Test Email' }), request.arguments['headers']
      assert request.arguments['content'].blank?
    end
    
    def test_create_with_text_only_view
      assert request = Notifier.create_with_text_only_view
      assert_equal 'text only: plain text', request.arguments['content']['text/plain']
    end
    
    def test_create_with_html_and_text_views
      assert request = Notifier.create_with_html_and_text_views
      assert_equal 'html and text: plain text', request.arguments['content']['text/plain']
      assert_equal 'html and text: html', request.arguments['content']['text/html']
    end
    
    def test_deliver_with_html_and_text_views
      mock_successful_send
      
      assert response = Notifier.deliver_with_html_and_text_views
      assert response.is_a?(PostageApp::Response)
      assert response.ok?
    end
    
    def test_create_with_simple_view
      assert request = Notifier.create_with_simple_view
      assert_equal 'simple view content', request.arguments['content']['text/plain']
    end
    
    def test_create_with_manual_parts
      assert request = Notifier.create_with_manual_parts
      assert_equal 'text content', request.arguments['content']['text/plain']
      assert_equal 'html content', request.arguments['content']['text/html']
      assert !request.arguments['attachments'].blank?
      assert !request.arguments['attachments']['foo.jpg']['content'].blank?
      assert_equal 'image/jpeg', request.arguments['attachments']['foo.jpg']['content_type']
    end
    
    def test_create_with_body_and_attachment
      assert request = Notifier.create_with_body_and_attachment
      assert !request.arguments['content'].blank?
      assert !request.arguments['content']['text/plain'].blank?
      assert_equal 'body text', request.arguments['content']['text/plain']
      assert !request.arguments['attachments'].blank?
      assert !request.arguments['attachments']['foo.jpg']['content'].blank?
      assert_equal 'image/jpeg', request.arguments['attachments']['foo.jpg']['content_type']
    end
    
    def test_create_with_custom_postage_variables
      assert request = Notifier.create_with_custom_postage_variables
      assert_equal 'test_template', request.arguments['template']
      assert_equal ({ 'variable' => 'value' }), request.arguments['variables']
      assert_equal ({ 'test2@test.text' => { 'name' => 'Test 2'}, 
                      'test1@test.text' => { 'name' => 'Test 1'}}), request.arguments['recipients']
    end
    
    def test_create_with_recipient_override
      PostageApp.configuration.recipient_override = 'oleg@test.test'
      assert request = Notifier.create_with_html_and_text_views
      assert_equal 'oleg@test.test', request.arguments_to_send['arguments']['recipient_override']
    end
  end
  
end