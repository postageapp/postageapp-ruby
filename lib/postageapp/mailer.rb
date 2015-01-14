require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR == 4
  require File.expand_path('../mailer/mailer_4', __FILE__)
elsif ActionMailer::VERSION::MAJOR == 3
  require File.expand_path('../mailer/mailer_3', __FILE__)
else
  require File.expand_path('../mailer/mailer_2', __FILE__)
end

# General helper methods for Request object to act more like TMail::Mail
# of Mail for testing
class PostageApp::Request
  # Getter and setter for headers. You can specify headers in the following
  # formats:
  #   headers['Custom-Header'] = 'Custom Value'
  #   headers 'Custom-Header-1' => 'Custom Value 1',
  #           'Custom-Header-2' => 'Custom Value 2'
  def headers(value = nil)
    _headers = self.arguments['headers'] ||= { }

    case (value)
    when Hash
      value.each do |k, v|
        _headers[k.to_s] = v.to_s
      end
    end

    _headers
  end

  def [](key)
    case (key)
    when :to, 'to'
      self.to
    when :from, 'from'
      self.from
    when :bcc, 'bcc'
      # Not supported via API at this time
      [ ]
    end
  end

  def to
    out = self.arguments_to_send.dig('arguments', 'recipients')
    out.is_a?(Hash) ? out : [out].flatten
  end

  def to=(list)
    self.arguments['recipients'] = list
  end

  def from
    [ self.arguments_to_send.dig('arguments', 'headers', 'from') ].flatten
  end

  def from=(address)
    _headers = self.arguments['headers'] ||= { }

    _headers['from'] = address.to_s
  end

  def bcc
    # Not supported via API at this time
    [ ]
  end

  def bcc=(list)
    # Not supported via API at this time
  end

  def subject
    self.arguments_to_send.dig('arguments', 'headers', 'subject')
  end

  def subject=(subject)
    _headers = self.arguments['headers'] ||= { }

    _headers['subject'] = subject.to_s
  end

  def body
    out = self.arguments_to_send.dig('arguments', 'content')
    out.is_a?(Hash) ? out.values.join("\n\n") : out.to_s
  end
end
