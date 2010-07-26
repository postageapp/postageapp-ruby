require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR >= 3
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
    self.arguments['headers'] ||= { }
    if value && value.is_a?(Hash)
      value.each do |k, v|
        self.arguments['headers'][k.to_s] = v.to_s
      end
    end
    self.arguments['headers']
  end
  
  def to
    out = self.arguments_to_send.dig('arguments', 'recipients')
    out.is_a?(Hash) ? out : [out].flatten
  end
  
  def from
    [self.arguments_to_send.dig('arguments', 'headers', 'from')].flatten
  end
  
  def subject
    self.arguments_to_send.dig('arguments', 'headers', 'subject')
  end
  
  def body
    out = self.arguments_to_send.dig('arguments', 'content')
    out.is_a?(Hash) ? out.values.join("\n\n") : out.to_s
  end
  
end