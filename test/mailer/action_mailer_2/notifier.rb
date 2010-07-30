# Test mailer for ActionMailer 2
class Notifier < PostageApp::Mailer
  
  self.template_root = File.expand_path('../', __FILE__)
  
  def blank
    # ... nothing to see here
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
    part  :content_type => 'text/html',
          :body         => 'html content'
    part  :content_type => 'text/plain',
          :body         => 'text content'
    attachment  :content_type => 'image/jpeg',
                :filename     => 'foo.jpg',
                :body         => '123456789'
  end
  
  def with_body_and_attachment
    setup_headers
    attachment  :content_type => 'image/jpeg',
                :filename     => 'foo.jpg',
                :body         => '123456789'
  end
  
  def with_custom_postage_variables
    from    'test@test.test'
    subject 'Test Email'
    
    recipients ({
      'test1@test.text' => { 'name' => 'Test 1' },
      'test2@test.text' => { 'name' => 'Test 2' }
    })
    postageapp_template 'test-template'
    postageapp_variables 'variable' => 'value'
  end
  
private
  
  def setup_headers
    recipients 'test@test.test'
    from       'text@test.test'
    subject    'Test Email'
  end
  
end
