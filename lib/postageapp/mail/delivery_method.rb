class PostageApp::Mail::DeliveryMethod
  def self.deliveries
    @deliveries ||= [ ]
  end

  def initialize(options)
    @options = options.dup
  end

  def deliver!(mail)
    api_method, arguments = PostageApp::Mail::Arguments.new(mail).extract

    case (@options[:api_key])
    when false
      self.class.deliveries << [ api_method, arguments ]
    else
      arguments['api_key'] ||= @options[:api_key]

      PostageApp::Request.new(api_method, arguments).send
    end
  end
end
