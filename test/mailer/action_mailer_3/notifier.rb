# Test mailer for ActionMailer 3
class Notifier < PostageApp::Mailer
  
  self.append_view_path(File.expand_path('../../templates', __FILE__))
  
  def blank
    # ...
  end
  
  # def with_no_content
  #   setup_headers
  # end
  # 
  # def with_text_only_view
  #   setup_headers
  # end
  # 
  # def with_html_and_text_views
  #   setup_headers
  # end
  # 
  # def with_simple_view
  #   setup_headers
  # end
  # 
  # def with_manual_parts
  #   setup_headers
  #   part  :content_type => 'text/html',
  #         :body         => 'html content'
  #   part  :content_type => 'text/plain',
  #         :body         => 'text content'
  #   attachment  :content_type => 'image/jpeg', 
  #               :filename     => 'foo.jpg',
  #               :body         => '123456789'
  # end
  # 
  # def with_body_and_attachment
  #   setup_headers
  #   attachment  :content_type => 'image/jpeg',
  #               :filename     => 'foo.jpg',
  #               :body         => '123456789'
  # end
  #
  
  def with_custom_postage_variables
    postage_template 'test_template'
    postage_variables 'variable' => 'value'
    
    mail(
      :from     => 'test@test.test',
      :subject  => 'Test Message',
      :to       => {
        'test1@test.text' => { 'name' => 'Test 1' },
        'test2@test.text' => { 'name' => 'Test 2' }
      }
    )
  end
  
private
  
  def setup_headers
    recipients 'test@test.test'
    from       'text@test.test'
    subject    'Test Email'
  end
  
end