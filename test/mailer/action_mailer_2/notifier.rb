# Test mailer for ActionMailer 2.x

class Notifier < PostageApp::Mailer
  self.template_root = File.dirname(__FILE__)

  def blank
    # Empty method
  end
  
  def with_no_content
    setup_headers
  end
  
  def with_text_only_view
    setup_headers
  end
  
  def with_html_and_text_views
    setup_headers
  end
  
  def with_simple_view
    setup_headers
  end
  
  def with_manual_parts
    setup_headers

    part(
      :content_type => 'text/html',
      :body => 'html content'
    )

    part(
      content_type: 'text/plain',
      body: 'text content'
    )

    attachment(
      content_type: 'image/jpeg',
      filename: 'foo.jpg',
      body: '123456789'
    )
  end
  
  def with_body_and_attachment
    setup_headers

    attachment(
      content_type: 'image/jpeg',
      filename: 'foo.jpg',
      body: '123456789'
    )
  end
  
  def with_custom_postage_variables
    postageapp_template 'test-template'
    postageapp_variables 'variable' => 'value'
    postageapp_uid 'custom_uid'
    postageapp_api_key 'custom_api_key'
    
    from 'sender@example.com'
    subject 'Test Email'
    
    recipients(
      'test1@example.net' => { 'name' => 'Test 1' },
      'test2@example.net' => { 'name' => 'Test 2' }
    )
  end
  
private
  def setup_headers
    recipients 'recipient@example.net'
    from 'sender@example.com'
    subject 'Test Email'
  end
end
