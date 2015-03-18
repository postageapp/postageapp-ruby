class PostageApp::Mail::DeliveryMethod
  def self.deliveries
    @deliveries ||= [ ]
  end

  def initialize(options)
    @options = options.dup
  end

  def deliver!(mail)
    arguments = PostageApp::Mail::Arguments.new(mail).extract

    case (@options[:api_key])
    when false
      self.class.deliveries << arguments
    else
      # ... Send, perhaps?
    end
  end
end
