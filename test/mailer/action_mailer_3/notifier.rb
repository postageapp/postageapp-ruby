# Test mailer for ActionMailer 3
class Notifier < PostageApp::Mailer

  self.append_view_path(File.expand_path('../', __FILE__))

  def blank
    # ... nothing to see here
  end

  def with_no_content
    mail(headers_hash)
  end

  def with_no_subject
    hash_without_subject = headers_hash
    hash_without_subject.delete(:subject)
    mail(hash_without_subject)
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

  def with_body_and_attachment_as_file
    attachments['sample_file.txt'] = 'File content'
    mail(headers_hash) do |format|
      format.html { render :text => 'manual body text'}
    end
  end

  def with_body_and_attachment_as_hash
    attachments['sample_file.txt'] = {
      :content_type => 'text/rich',
      :body         => 'File content'
    }
    mail(headers_hash) do |format|
      format.html { render :text => 'manual body text'}
    end
  end

  def with_custom_postage_variables
    headers['CustomHeader1'] = 'CustomValue1'
    headers 'CustomHeader2' => 'CustomValue2'

    postageapp_template   'test-template'
    postageapp_variables  'variable' => 'value'
    postageapp_api_key    'custom_api_key'
    postageapp_uid        'custom_uid'

    mail(
      :from     => 'test@test.test',
      :subject  => 'Test Message',
      :to       => {
        'test1@test.test' => { 'name' => 'Test 1' },
        'test2@test.test' => { 'name' => 'Test 2' }
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