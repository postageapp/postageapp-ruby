require File.expand_path('../helper', __FILE__)

# tests for ActionMailer bundled with Rails 3
class Mailer3Test < Test::Unit::TestCase
  
  if ActionMailer::VERSION::MAJOR >= 3
    
    require File.expand_path('../mailer/action_mailer_3/notifier', __FILE__)
    puts "\e[0m\e[32mRunning #{File.basename(__FILE__)} for action_mailer #{ActionMailer::VERSION::STRING}\e[0m"
    
    def test_create_blank
      flunk 'todo'
    end
    
    def test_create_with_no_content
      flunk 'todo'
    end
    
    def test_create_with_simple_view
      mail = Notifier3.with_simple_view
      assert_equal 'simple view content', mail.arguments['content']['text/html']
    end
    
    def test_create_with_text_only_view
      mail = Notifier3.with_text_only_view
      assert_equal 'text content', mail.arguments['content']['text/plain']
    end
    
    def test_create_with_html_and_text_views
      mail = Notifier3.with_html_and_text_views
      assert_equal 'text content', mail.arguments['content']['text/plain']
      assert_equal 'html content', mail.arguments['content']['text/html']
    end
    
    def test_deliver_with_html_and_text_views
      flunk 'todo'
    end
    
    def test_create_with_body_and_attachment_as_file
      mail = Notifier3.with_body_and_attachment_as_file
      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/plain', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end
    
    def test_create_with_body_and_attachment_as_hash
      mail = Notifier3.with_body_and_attachment_as_hash
      assert_equal 'manual body text', mail.arguments['content']['text/html']
      assert_equal 'text/rich', mail.arguments['attachments']['sample_file.txt']['content_type']
      assert_equal "RmlsZSBjb250ZW50\n", mail.arguments['attachments']['sample_file.txt']['content']
    end
    
    def test_create_with_custom_postage_variables
      flunk 'todo'
    end
    
    def test_create_with_old_api
      flunk 'todo'
    end
    
    def test_create_with_recipient_override
      flunk 'todo'
    end
    
  else
    puts "\e[0m\e[31mSkipping #{File.basename(__FILE__)}\e[0m"
    def test_nothing ; end
  end
end