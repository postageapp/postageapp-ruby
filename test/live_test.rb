require File.expand_path('../helper', __FILE__)

class LiveTest < Test::Unit::TestCase
  
  # Note: Need access to a live PostageApp.com account
  # See helper.rb to set host / api key
  unless false # set to +true+ to run tests
    puts "\e[0m\e[31mSkipping #{File.basename(__FILE__)}\e[0m"
    def test_nothing ; end
  else
    
    def setup
      super
      PostageApp.configure do |config|
        config.secure   = false
        config.host     = 'api.postageapp.local'
        config.api_key  = 'PROJECT_API_KEY'
      end
    end
    
    def test_request_get_method_list
      request = PostageApp::Request.new(:get_method_list)
      response = request.send
      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'ok', response.status
      assert_match /^\w{40}$/, response.uid
      assert_equal nil, response.message
      assert_equal ({
        'methods' => 'get_account_info, get_message_receipt, get_method_list, get_project_info, send_message'
      }), response.data
    end
    
    def test_request_send_message
      request = PostageApp::Request.new(:send_message, {
        :headers    => { 'from'     => 'sender@test.test',
                         'subject'  => 'Test Message'},
        :recipients => 'test@test.test',
        :content    => {
          'text/plain'  => 'text content',
          'text/html'   => 'html content'
        }
      })
      response = request.send
      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'ok', response.status
      assert_match /^\w{40}$/, response.uid
      assert_equal nil, response.message
      assert_match /\d+/, response.data['message']['id'].to_s
      
      receipt = PostageApp::Request.new(:get_message_receipt, :uid => response.uid).send
      assert receipt.ok?
      
      receipt = PostageApp::Request.new(:get_message_receipt, :uid => 'bogus').send
      assert receipt.not_found?
    end
    
    def test_request_non_existant_method
      request = PostageApp::Request.new(:non_existant)
      response = request.send
      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'internal_server_error', response.status
      assert_match /^\w{40}$/, response.uid
      assert_equal 'No action responded to non_existant. Actions: get_account_info, get_message_receipt, get_method_list, get_project_info, and send_message', response.message
      assert_equal nil, response.data
    end
    
    # Testable under ruby 1.9.2 Probably OK in production too... Probably
    # Lunchtime reading: http://ph7spot.com/musings/system-timer
    def test_request_timeout
      PostageApp.configuration.host = 'dead.postageapp.local'
      request = PostageApp::Request.new(:get_method_list)
      response = request.send
      assert_equal 'PostageApp::Response', response.class.name
      assert_equal 'fail', response.status
    end
    
    def test_deliver_with_custom_postage_variables
      response = if ActionMailer::VERSION::MAJOR < 3
        require File.expand_path('../mailer/action_mailer_2/notifier', __FILE__)
        Notifier.deliver_with_custom_postage_variables
      else
        require File.expand_path('../mailer/action_mailer_3/notifier', __FILE__)
        Notifier.with_custom_postage_variables.deliver
      end
      assert response.ok?
    end
    
  end
end