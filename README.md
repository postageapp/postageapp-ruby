# [PostageApp](http://postageapp.com) Ruby Gem [![Build Status](https://secure.travis-ci.org/postageapp/postageapp-ruby.png)](http://travis-ci.org/postageapp/postageapp-ruby)

This is the gem used to integrate Ruby apps with PostageApp service.
Personalized, mass email sending can be offloaded to PostageApp via JSON based API.

### [API Documentation](http://help.postageapp.com/kb/api/api-overview) &bull; [Knowledge Base](http://help.postageapp.com/kb) &bull; [Help Portal](http://help.postageapp.com)

Installation
------------

### Rails 3 / 4
Add postageapp gem to your Gemfile:

    gem 'postageapp'

Then from the Rails project's root run:

    bundle install
    script/rails generate postageapp --api-key PROJECT_API_KEY

### Rails 2
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

```ruby
require 'postageapp'

PostageApp.configure do |config|
  config.api_key = 'PROJECT_API_KEY'
end
```

Usage
-----
Here's an example of sending a message ([See full API documentation](http://help.postageapp.com/faqs/api/send_message)):

```ruby
request = PostageApp::Request.new(:send_message, {
  'headers'     => { 'from'     => 'sender@example.com',
                     'subject'  => 'Email Subject' },
  'recipients'  => 'recipient@example.com',
  'content'     => {
    'text/plain'  => 'text email content',
    'text/html'   => 'html email content'
  },
  'attachments' => {
    'document.pdf' => {
      'content_type'  => 'application/pdf',
      'content'       => Base64.encode64(File.open('/path/to/document.pdf', 'rb').read)
    }
  }
})
response = request.send
```

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
Sometimes you don't want to send emails to real people in your application. For that there's an ability to override to what address all emails will be delivered. All you need to do is modify configuration block like this (in Rails projects it's usually found in `RAILS_ROOT/config/initializers/postageapp.rb`):

```ruby
PostageApp.configure do |config|
  config.api_key            = 'PROJECT_API_KEY'
  config.recipient_override = 'you@example.com' unless Rails.env.production?
end
```

ActionMailer Integration
------------------------
You can quickly convert your existing mailers to use PostageApp service by simply changing `class MyMailer < ActionMailer::Base` to `class MyMailer < PostageApp::Mailer`.  If you using ActionMailer from outside of Rails make sure you have this line somewhere: `require 'postageapp/mailer'`

There are custom methods that allow setting of `template` and `variables` parts of the API call. They are `postageapp_template` and `postageapp_variables`. Examples how they are used are below. For details what they do please see [documentation](http://help.postageapp.com/faqs)

Please note that `deliver` method will return `PostageApp::Response` object. This way you can immediately check the status of the delivery. For example:

    >> response = UserMailer.welcome_email(@user).deliver
    >> response.ok?
    => true

### Rails 3 / 4

Here's an example of a mailer in Rails 3 environment:

```ruby
require 'postageapp/mailer'

class Notifier < PostageApp::Mailer

  def signup_notification

    attachments['example.zip'] = File.read('/path/to/example.zip')

    headers['Special-Header'] = 'SpecialValue'

    # PostageApp specific elements:
    postageapp_template 'example_template'
    postageapp_variables 'global_variable' => 'value'

    # You may set api key for a specific mailers
    postageapp_api_key '123456abcde'

    # You can manually specify uid for the message payload.
    # Make sure it's sufficiently unique.
    postageapp_uid Digest::SHA1.hexdigest([@user.id, Time.now].to_s)

    mail(
      :from     => 'test@test.test',
      :subject  => 'Test Message',
      :to       => {
        'recipient_1@example.com' => { 'variable' => 'value' },
        'recipient_2@example.com' => { 'variable' => 'value' }
      })
  end
end
```

API of previous ActionMailer is partially supported under Rails 3 environment. Please note that it's not 100% integrated, some methods/syntax will not work. You may still define you mailers in this way (but really shouldn't):

```ruby
require 'postageapp/mailer'

class Notifier < PostageApp::Mailer

  def signup_notification
    from        'sender@example.com'
    subject     'Test Email'
    recipients  'recipient@example.com'
  end
end
```

#### Interceptors

Here's an example of using an interceptor

```ruby
class DevelopmentPostageappInterceptor
  def self.delivering_email(postageapp_msg)
    postageapp_msg.arguments["headers"][:subject] =
      "[#{postageapp_msg.arguments["recipients"]}] #{postageapp_msg.arguments["headers"][:subject]}"
    postageapp_msg.arguments["recipients"] = "test@example.com"
    # postageapp_msg.perform_deliveries = false
  end
end
```

### Rails 2

Here's an example of a mailer you'd set in in a Rails 2 environment:

```ruby
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
    postageapp_template 'example_template'
    postageapp_variables 'global_variable' => 'value'

  end
end
```

Automatic resending in case of failure
--------------------------------------
For those ultra rare occasions when api.postageapp.com is not reachable this gem will temporarily store requests and then will attempt to resend them with the next successful connection. In Rails environment it will create a folder: `RAILS_ROOT/tmp/postageapp_failed_requests` and save all failed requests there. On successful resend file for that request will be deleted.

For projects other than Rails you'll need to tell where there project_root is at:

```ruby
PostageApp.configure do |config|
  config.api_key      = 'PROJECT_API_KEY'
  config.project_root = "/path/to/your/project"
end
```

Copyright
---------
(C) 2011-2014 Oleg Khabarov, [The Working Group, Inc](http://www.twg.ca/)
