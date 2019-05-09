# [PostageApp](https://postageapp.com/) Ruby Gem [![Build Status](https://secure.travis-ci.org/postageapp/postageapp-ruby.png)](http://travis-ci.org/postageapp/postageapp-ruby)

This gem is used to integrate Ruby apps with [PostageApp](https://postageapp.com/)
service. Personalized high-volume email sending can be offloaded to PostageApp
via a simple [JSON-based API](https://dev.postageapp.com/api).

### [API Documentation](https://dev.postageapp.com/api/)

# Installation

## Rails 5.2 and newer

Add the `postageapp` gem to your Gemfile:

    gem 'postageapp'

Then from the Rails project's root run:

    bundle install

For authentication, add your project's PostageApp credentials to the
Rails Encrypted Credentials:

    rails credentials:edit

The format of this entry should be:

    postageapp:
      api_key: __PROJECT_API_KEY__

Where that will be picked up by the plugin when Rails starts.

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

Add the `postageapp` gem to your Gemfile:

    gem 'postageapp'

Then from the project's root run:

    bundle install

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
[`send_message`](https://dev.postageapp.com/api/send_message) API call:

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
        content_type: 'application/pdf',
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
[documentation](https://dev.postageapp.com/api/)

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
  config.api_key = 'PROJECT_API_KEY'
  config.project_root = "/path/to/your/project"
end
```

# Configuration Details

Configuration can be done either via Ruby code directly, by environment
variables, or by a combination of both. Where both are supplied, the
Ruby setting will take precedence.

## Configuration Arguments

These can all be set with `PostageApp.config`:

* `api_key`: Project API key to use (required for project API functions)
* `account_api_key`: Account API key to use (required for account API functions)
* `postback_secret`: Secret to use for validating ActionMailbox requests (optional)
* `project_root`: Project root for logging purposes (default: current working directory)
* `recipient_override`: Override sender on `send_message` calls (optional)
* `logger`: Logger instance to use (optional)
* `secure`: Enable verifying TLS connections (default: `true`)
* `verify_tls`: Enable TLS certificate verification (default: `true`)
* `verify_certificate`: Alias for `verify_tls`
* `host`: API host to contact (default: `api.postageapp.com`)
* `port`: API port to contact (default: `443`)
* `scheme`: HTTP scheme to use (default: `https`)
* `protocol`: Alias for `scheme`
* `proxy_username`: SOCKS5 proxy username (optional)
* `proxy_user`: Alias for `proxy_username`
* `proxy_password`: SOCKS5 proxy password (optional)
* `proxy_pass`: Alias for `proxy_password`
* `proxy_host`: SOCKS5 proxy host (optional)
* `proxy_port`: SOCKS5 proxy port (default: `1080`)
* `open_timeout`: Timeout in seconds when initiating requests (default: `5`)
* `http_open_timeout`: Alias for `open_timeout`
* `read_timeout`: Timeout in seconds when awaiting responses (default: `10`)
* `http_read_timeout`: Alias for `read_timeout`
* `retry_methods`: Which API calls to retry, comma and/or space separated (default: `send_message`)
* `requests_to_resend`: Alias for `retry_methods`
* `framework`: Framework used (default: `Ruby`)
* `environment`: Environment to use (default: `production`)

A typical configuration involves setting the project API key:

    PostageApp.config do |config|
      config.api_key = 'PROJECT_API_KEY'
    end

Where additional settings can be applied as necessary.

## Environment Variables

Most configuration parameters can be set via the environment:

* `POSTAGEAPP_API_KEY`: Project API key to use (required for project API functions)
* `POSTAGEAPP_ACCOUNT_API_KEY`: Account API key to use (required for account API functions)
* `POSTAGEAPP_POSTBACK_SECRET`: Secret to use for validating ActionMailbox requests (optional)
* `POSTAGEAPP_PROJECT_ROOT`: Project root for logging purposes (default: current working directory)
* `POSTAGEAPP_RECIPIENT_OVERRIDE`: Override sender on `send_message` calls (optional)
* `POSTAGEAPP_VERIFY_TLS`:  (default: `true`)
* `POSTAGEAPP_VERIFY_CERTIFICATE`: Alias for `POSTAGEAPP_VERIFY_TLS`
* `POSTAGEAPP_HOST`: API host to contact (default: `api.postageapp.com`)
* `POSTAGEAPP_PORT`: API port to contact (default: `443`)
* `POSTAGEAPP_SCHEME`: HTTP scheme to use (default: `https`)
* `POSTAGEAPP_PROTOCOL`: Alias for `POSTAGEAPP_SCHEME`
* `POSTAGEAPP_PROXY_USERNAME`: SOCKS5 proxy username (optional)
* `POSTAGEAPP_PROXY_USER`: Alias for `POSTAGEAPP_PROXY_USERNAME`
* `POSTAGEAPP_PROXY_PASSWORD`: SOCKS5 proxy password (optional)
* `POSTAGEAPP_PROXY_PASS`: Alias for `POSTAGEAPP_PROXY_PASSWORD`
* `POSTAGEAPP_PROXY_HOST`: SOCKS5 proxy host (optional)
* `POSTAGEAPP_PROXY_PORT`: SOCKS5 proxy port (default: `1080`)
* `POSTAGEAPP_OPEN_TIMEOUT`: Timeout in seconds when initiating requests (default: `5`)
* `POSTAGEAPP_HTTP_OPEN_TIMEOUT`: Alias for `POSTAGEAPP_OPEN_TIMEOUT`
* `POSTAGEAPP_READ_TIMEOUT`: Timeout in seconds when awaiting responses (default: `10`)
* `POSTAGEAPP_HTTP_READ_TIMEOUT`: Alias for `POSTAGEAPP_READ_TIMEOUT`
* `POSTAGEAPP_RETRY_METHODS`: Which API calls to retry, comma and/or space separated (default: `send_message`)
* `POSTAGEAPP_REQUESTS_TO_RESEND`: Alias for `POSTAGEAPP_RETRY_METHODS`
* `POSTAGEAPP_FRAMEWORK`: Framework used (default: `Ruby`)
* `POSTAGEAPP_ENVIRONMENT`: Environment to use (default: `production`)

# Copyright and Licensing

(C) 2011-2019 Scott Tadman, Oleg Khabarov, [PostageApp](https://postageapp.com/)

This is released under the [MIT License](LICENSE.md).
