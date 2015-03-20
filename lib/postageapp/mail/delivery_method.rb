class PostageApp::Mail::DeliveryMethod
  def self.deliveries
    @deliveries ||= [ ]
  end

  # Creates a new DeliveryMethod instance with the supplied options.
  def initialize(options)
    @options = options.dup
  end

  # Delivers a given Mail::Message through PostageApp using the configuration
  # specified through Mail defaults or settings applied to ActionMailer.
  def deliver!(mail)
    api_method, arguments = PostageApp::Mail::Arguments.new(mail).extract

    case (@options[:api_key])
    when false, :test
      # In testing mode, just capture the calls that would have been made so
      # they can be inspected later using the deliveries class method.
      self.class.deliveries << [ api_method, arguments ]
    when nil
      # If the API key is not defined, raise an error providing a hint as to
      # how to set that correctly.
      raise PostageApp::Error,
        "PostageApp API key not defined: Add :api_key to config.action_mailer.postageapp_settings to config/application.rb"
    else
      arguments['api_key'] ||= @options[:api_key]

      PostageApp::Request.new(api_method, arguments).send
    end
  end
end
