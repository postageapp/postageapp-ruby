require 'action_mailer'
require 'action_mailer/version'

# Loading PostageApp::Mailer class depending on what action_mailer is
# currently installed on the system. Assuming we're dealing only with
# ones that come with Rails 2 and 3
if ActionMailer::VERSION::MAJOR >= 3
  require File.expand_path('../mailer/mailer_am3', __FILE__)
else
  require File.expand_path('../mailer/mailer_am2', __FILE__)
end

# TODO: Add helper methods for PostageApp::Request so it can be tested as a TMail::Mail / Mail object