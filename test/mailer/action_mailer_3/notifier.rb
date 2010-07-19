# Test mailer for ActionMailer 3
class Notifier3 < PostageApp::Mailer
  
  self.append_view_path(File.expand_path('../../templates', __FILE__))
  
  def blank
    # ...
  end
  
  def with_no_content
    
  end
  
  def with_text_only_view
    mail(headers_hash)
  end
  
  def with_html_and_text_views
    mail(headers_hash) do |format|
      format.text
      format.html
    end
  end
  
  def with_simple_view
    mail(headers_hash)
  end
  
  def with_manual_parts
    
  end
  
  def with_body_and_attachment
    attachments['sample_file.txt'] = 'File content'
    mail(headers_hash) do |format|
      format.html { render :text => 'manual body text'}
    end
  end
  
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
  
  def headers_hash(options = {})
    { :from     => 'sender@test.test',
      :subject  => 'Test Message',
      :to       => 'test@test.test'
    }.merge(options)
  end
  
end