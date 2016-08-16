# Rails 2.x

These notes describe behavior specific to the Rails 2.x environment. Unless
otherwise specified the approach in the main documentation applies.

## Installation

In `config/environment.rb` add the following:

    config.gem 'postageapp'

Then from the Rails project's root run:

    rake gems:install
    rake gems:unpack GEM=postageapp
    script/generate postageapp --api-key PROJECT_API_KEY

## Mailer Creation

Here's an example of a mailer you'd set in in a Rails 2 environment:

```ruby
require 'postageapp/mailer'

class Notifier < PostageApp::Mailer
  def signup_notification
    from 'system@example.com'
    subject 'New Account Information'

    # Recipients can be in any format API allows.
    # Here's an example of a hash format
    recipients(
      'recipient_1@example.com' => {
        'variable_name_1' => 'value',
        'variable_name_2' => 'value'
      },
      'recipient_2@example.com' => {
        'variable_name_1' => 'value',
        'variable_name_2' => 'value'
      },
    )

    attachment(
      :content_type => 'application/zip',
      :filename => 'example.zip',
      :body => File.read('/path/to/example.zip'
    )

    # PostageApp specific elements:
    postageapp_template 'example_template'
    postageapp_variables 'global_variable' => 'value'
  end
end
```
