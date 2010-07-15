class TestNotifier < PostageApp::Mailer
  
  self.template_root = File.dirname(__FILE__) + '/templates/'
  
  def blank
    # ...
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
    setup_headers
    
    postage_template 'test_template'
    postage_variables :variable => 'value'
  end
  
private

  def setup_headers
    recipients 'test@test.test'
    from       'text@test.test'
    subject    'Test Email'
  end
  
end