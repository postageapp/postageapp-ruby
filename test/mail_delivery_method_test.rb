require File.expand_path('helper', File.dirname(__FILE__))

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
          'To' => 'recipient@example.net',
          'Subject' => 'Example message being sent through Mail'
        }
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
          'To' => 'recipient@example.net',
          'Subject' => 'Example message being sent through Mail'
        }
      }
    ]

    assert_equal expected, api_call
  end

  def test_text_body_with_attachment
  end

  def test_html_body_with_attachment
  end

  def test_html_and_text
  end

  def test_html_and_text_with_attachment
  end
end
