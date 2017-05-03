# [PostageApp](http://postageapp.com) Ruby Gem [![Build Status](https://secure.travis-ci.org/postageapp/postageapp-ruby.png)](http://travis-ci.org/postageapp/postageapp-ruby)

This gem is used to integrate Ruby apps with [PostageApp](http://postageapp.com/)
service. Personalized high-volume email sending can be offloaded to PostageApp
via a simple [JSON-based API](http://dev.postageapp.com/api.html).

### [API Documentation](http://help.postageapp.com/kb/api/api-overview) &bull; [Knowledge Base](http://help.postageapp.com/kb) &bull; [Help Portal](http://help.postageapp.com/)

# Installation

## Rails 4.x and newer

Add the `postageapp` gem to your Gemfile:

    gem 'postageapp'

Then from the Rails project's root run:

    bundle install
    bin/rails generate postageapp --api-key PROJECT_API_KEY

## Legacy Versions of Rails

* [Rails 3.x](doc/RAILS3.md)
* [Rails 2.3.x](doc/RAILS2.md)

## Sinatra / Rack / Others

You'll need to install the gem first:

    $ sudo gem install postageapp

The configuration will need to be loaded before executing any API calls:

```ruby
require 'postageapp'

PostageApp.configure do |config|
  config.api_key = 'PROJECT_API_KEY'
end
```

If it's more convenient, setting the `POSTAGEAPP_API_KEY` environment variable
with the appropriate API key will also work.

# Usage

Here's an example of sending a message using the
[`send_message`](http://help.postageapp.com/faqs/api/send_message) API call:

```ruby
request = PostageApp::Request.new(
  :send_message,
  {
    headers: {
      from: 'sender@example.com',
      subject: 'Email Subject'
    },
    recipients: 'recipient@example.com',
    content: {
      'text/plain' => 'text email content',
      'text/html' => 'html email content'
    },
    attachments: {
      'document.pdf' => {
        content_type: application/pdf',
        content: Base64.encode64(File.open('/path/to/document.pdf', 'rb').read)
      }
    }
  }
)

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

# Recipient Override

Sometimes you don't want to send emails to real people in your application. For
that there's an ability to override to what address all emails will be
delivered. All you need to do is modify configuration block like this (in Rails
projects it's usually found in `RAILS_ROOT/config/initializers/postageapp.rb`):

```ruby
PostageApp.configure do |config|
  config.api_key = 'PROJECT_API_KEY'

  unless (Rails.env.production?)
    config.recipient_override = 'you@example.com'
  end
end
```

# ActionMailer Integration

You can quickly convert your existing mailers to use PostageApp service by
simply changing `class MyMailer < ActionMailer::Base` to
`class MyMailer < PostageApp::Mailer`. When using ActionMailer from outside
of Rails, this will have to be loaded manually:

```ruby
require 'postageapp/mailer'
```

There are custom methods that allow setting of `template` and `variables` parts
of the API call. They are `postageapp_template` and `postageapp_variables`.
Examples how they are used are below. For details what they do please see
[documentation](http://help.postageapp.com/faqs)

Please note that `deliver` method will return `PostageApp::Response` object.
This way you can immediately check the status of the delivery. For example:

    response = UserMailer.welcome_email(@user).deliver
    response.ok?
    # => true

## Mailer Base Class

Here's an example of a mailer using the `PostageApp::Mailer` base class:

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
    postageapp_uid Digest::SHA1.hexdigest([ @user.id, Time.now ].to_s)

    mail(
      from: 'test@test.test',
      subject: 'Test Message',
      to: {
        'recipient_1@example.com' => { 'variable' => 'value' },
        'recipient_2@example.com' => { 'variable' => 'value' }
      }
    )
  end
end
```

API of previous ActionMailer is partially supported under Rails 3 environment.
Please note that it's not 100% integrated, some methods/syntax will not work.
You may still define you mailers in this way (but really shouldn't):

```ruby
require 'postageapp/mailer'

class Notifier < PostageApp::Mailer
  def signup_notification
    from 'sender@example.com'
    subject 'Test Email'

    mail(to: 'recipient@example.com')
  end
end
```

#### Interceptors

Here's an example of using an interceptor:

```ruby
class DevelopmentPostageappInterceptor
  def self.delivering_email(postageapp_msg)
    postageapp_msg.arguments["headers"][:subject] =
      "[#{postageapp_msg.arguments["recipients"]}] #{postageapp_msg.arguments["headers"][:subject]}"

    postageapp_msg.arguments["recipients"] = "test@example.com"

    # Deliveries can be disabled if required
    # postageapp_msg.perform_deliveries = false
  end
end
```

# Automatic resending in case of failure

For those rare occasions when the API is not reachable or unresponsive,
this gem will temporarily store requests and then will attempt to resend them
with the next successful connection. In Rails environment it will create a
folder: `RAILS_ROOT/tmp/postageapp_failed_requests` and save all failed
requests there. On successful resend file for that request will be deleted.

For projects other than Rails you'll need to tell where the `project_root` is:

```ruby
PostageApp.configure do |config|
  config.api_key      = 'PROJECT_API_KEY'
  config.project_root = "/path/to/your/project"
end
```

# Copyright

(C) 2011-2017 Scott Tadman, Oleg Khabarov, [PostageApp](http://www.postageapp.com/)
