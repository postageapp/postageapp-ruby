require File.expand_path('../helper', __FILE__)

class MailerHelperMethodsTest < Test::Unit::TestCase
  
  def test_mailer_helper_methods
    request = PostageApp::Request.new(:send_message, {
      :headers    => { 'from'     => 'sender@test.test',
                       'subject'  => 'Test Message'},
      :recipients => 'test@test.test',
      :content    => {
        'text/plain'  => 'text content',
        'text/html'   => 'html content'
      }
    })
    assert_equal ['test@test.test'], request.to
    assert_equal ['sender@test.test'], request.from
    assert_equal 'Test Message', request.subject
    assert_equal "html content\n\ntext content", request.body
  end
  
end