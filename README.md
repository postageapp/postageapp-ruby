PostageApp Gem
==============

This is the gem used to integrate Ruby apps with PostageApp service. 

Installation
------------

### Rails 3.x
Add postageapp gem to your Gemfile:
    
    gem 'postageapp'
    
Then from the Rails project's root run:
    
    bundle install
    script/rails generate postageapp --api-key PROJECT_API_KEY
  
### Rails 2.x
In config/environment.rb add the following:
    
    config.gem 'postageapp'
    
Then from the Rails project's root run:
    
    rake gems:install
    rake gems:unpack GEM=postageapp
    script/generate postageapp --api-key PROJECT_API_KEY

### Sinatra / Rack / Others
You'll need to install the gem first:
    
    $ sudo gem install postageapp
    
And then it's as simple as doing something like this:
    
    require 'postageapp'
    
    PostageApp.configure do |config|
      config.api_key = 'PROJECT_API_KEY'
    end

Usage
-----
Here's an example of sending a message ([See full API documentation](http://TODO/)):
  
    request = PostageApp::Request.new(:send_message, {
      'headers'     => { 'from'     => 'sender@example.com',
                         'subject'  => 'Email Subject' },
      'recipients'  => 'recipient@example.com',
      'content'     => {
        'text/plain'  => 'text email content',
        'text/html'   => 'html email content'
      }
    })
    response = request.send
  
`PostageApp::Response` object allows you to check the status:
  
    >> response.status
    => 'ok'
  
Alternatively you may use:

    >> response.fail?
    => false
    >> response.ok?
    => true
  
Response usually comes back with data:
  
    >> response.data
    => { 'message' => { 'id' => '12345' }}
    
### Recipient Override
Sometimes you don't want to send emails to real people in your application. For that there's an ability to override to what address all emails will be delivered. All you need to do is modify configuration block like this:

    PostageApp.configure do |config|
      config.api_key            = 'PROJECT_API_KEY'
      config.recipient_override = 'you@example.com' unless Rails.env.production?
    end

ActionMailer Integration
------------------------
You can quickly convert your existing mailers to use PostageApp service by simply changing `class MyMailer < ActionMailer::Base` to `class MyMailer < PostageApp::Mailer`

### Rails 3.x

Here's an example of a mailer in Rails 3 environment:

    require 'postageapp/mailer'
    
    class Notifier < PostageApp::Mailer
    
      def signup_notification
        
        attachments['example.zip'] = File.read('/path/to/example.zip')
        
        headers['Special-Header'] = 'SpecialValue'
        
        # PostageApp specific elements:
        postage_template 'example_template'
        postage_variables 'global_variable' => 'value'
        
        mail(
          :from     => 'test@test.test',
          :subject  => 'Test Message',
          :to       => {
            'recipient_1@example.com' => { 'variable' => 'value' },
            'recipient_2@example.com' => { 'variable' => 'value' }
          })
      end
    end
  
API of previous ActionMailer is partially supported under Rails 3 environment. Please note that it's not 100% integrated, some methods/syntax will not work. You may still define you mailers in this way (but really shouldn't):

    require 'postageapp/mailer'
    
    class Notifier < PostageApp::Mailer
    
      def signup_notification
        from    'test@test.test'
        subject 'Test Email'
        recipients 'test@test.test'
      end
    end

### Rails 2.x

Here's an example of a mailer you'd set in in a Rails 2 environment:
    
    require 'postageapp/mailer'
    
    class Notifier < PostageApp::Mailer
      def signup_notification
        
        from        'system@example.com'
        subject     'New Account Information'
        
        # Recipients can be in any format API allows.
        # Here's an example of a hash format
        recipients  ({
          'recipient_1@example.com' => { 'variable_name_1' => 'value',
                                         'variable_name_2' => 'value' },
          'recipient_2@example.com' => { 'variable_name_1' => 'value',
                                         'variable_name_2' => 'value' },
        })
        
        attachment  :content_type => 'application/zip',
                    :filename     => 'example.zip',
                    :body         => File.read('/path/to/example.zip')
        
        # PostageApp specific elements:
        postage_template 'example_template'
        postage_variables 'global_variable' => 'value'
        
      end
    end

Copyright
---------
(C) 2010 [The Working Group, Inc](http://www.twg.ca/)
