require_relative './helper'

class MailerHelperMethodsTest < MiniTest::Test
  def test_mailer_helper_methods
    request = PostageApp::Request.new(
      :send_message,
      :headers => {
        'from' => 'sender@test.test',
        'subject' => 'Test Message'
      },
      :recipients => 'test@test.test',
      :content => {
        'text/plain' => 'text content',
        'text/html' => 'html content'
      }
    )

    assert_equal [ 'test@test.test' ], request.to
    assert_equal [ 'sender@test.test' ], request.from
    assert_equal 'Test Message', request.subject

    assert_match 'html content', request.body
    assert_match 'text content', request.body
  end
end
