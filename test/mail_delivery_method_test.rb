require_relative './helper'

class MailerDeliveryTest < MiniTest::Test
  def setup
    PostageApp::Mail::DeliveryMethod.deliveries.clear
  end

  def test_text
    mail = Mail.new do
      from 'test@example.com'
      to 'recipient@example.net'
      subject 'Example message being sent through Mail'
      body 'Example body text.'

      # add_file :filename => 'somefile.png', :content => File.read('/somefile.png')
    end

    mail.delivery_method :postageapp, api_key: false

    mail.deliver

    api_call = PostageApp::Mail::DeliveryMethod.deliveries.pop

    expected = [
      :send_message,
      {
        'content' => {
          'text/plain' => 'Example body text.'
        },
        'headers' => {
          'From' => 'test@example.com',
          'Subject' => 'Example message being sent through Mail'
        },
        'recipients' => [ 'recipient@example.net' ]
      }
    ]

    assert_equal expected, api_call
  end

  def test_html
    mail = Mail.new do
      from 'test@example.com'
      to 'recipient@example.net'
      subject 'Example message being sent through Mail'
      body '<p>Example body HTML text.</p>'

      content_type 'text/html'
    end

    mail.delivery_method :postageapp, api_key: false

    mail.deliver

    api_call = PostageApp::Mail::DeliveryMethod.deliveries.pop

    expected = [
      :send_message,
      {
        'content' => {
          'text/html' => '<p>Example body HTML text.</p>'
        },
        'headers' => {
          'From' => 'test@example.com',
          'Subject' => 'Example message being sent through Mail'
        },
        'recipients' => [ 'recipient@example.net' ]
      }
    ]

    assert_equal expected, api_call
  end

  def test_text_body_with_attachment
    mail = Mail.new do
      from 'test@example.com'
      to 'recipient@example.net'
      subject 'Example message being sent through Mail'

      body "Plain text"

      add_file :filename => 'test.txt', :content => 'Test text file.'
    end

    mail.delivery_method :postageapp, api_key: false

    mail.deliver

    api_call = PostageApp::Mail::DeliveryMethod.deliveries.pop

    expected = [
      :send_message,
      {
        'content' => {
          'text/plain' => 'Plain text'
        },
        'headers' => {
          'From' => 'test@example.com',
          'Subject' => 'Example message being sent through Mail'
        },
        'attachments' => {
          'test.txt' => {
            'content' => Base64.encode64('Test text file.'),
            'content_type' => 'text/plain; filename=test.txt'
          }
        },
        'recipients' => [ 'recipient@example.net' ]
      }
    ]

    assert_equal expected, api_call
  end

  def test_html_body_with_attachment
  end

  def test_html_and_text
    mail = Mail.new do
      from 'test@example.com'
      to 'recipient@example.net'
      subject 'Example message being sent through Mail'

      text_part do
        body "Plain text"
      end

      html_part do
        # Mail 2.2.20 requires a manual declaration of MIME type. Newer
        # versions handle this correctly.
        content_type 'text/html'
        body "<p>HTML text</p>"
      end
    end

    mail.delivery_method :postageapp, api_key: false

    mail.deliver

    api_call = PostageApp::Mail::DeliveryMethod.deliveries.pop

    expected = [
      :send_message,
      {
        'content' => {
          'text/plain' => 'Plain text',
          'text/html' => '<p>HTML text</p>'
        },
        'headers' => {
          'From' => 'test@example.com',
          'Subject' => 'Example message being sent through Mail'
        },
        'recipients' => [ 'recipient@example.net' ]
      }
    ]

    assert_equal expected, api_call
  end

  def test_html_and_text_with_attachment
  end
end
