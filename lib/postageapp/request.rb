class PostageApp::Request
  
  API_VERSION = '1.0'
  
  HEADERS = {
    'Content-type'  => 'application/json',
    'Accept'        => 'text/json, application/json'
  }
  
  # Unique ID of the request
  attr_accessor :uid
  
  # The API method being called (example: send_message)
  # This controls the url of the request (example: https://api.postageapp.com/v.1.0/send_message.json)
  attr_accessor :method
  
  # A list of arguments in a Hash format passed along with the request
  attr_accessor :arguments
  
  def initialize(method, arguments = {})
    @method     = method
    @uid        = arguments.delete(:uid)
    @arguments  = arguments
  end
  
  # Skipping resend doesn't trigger PostageApp::FailedRequest.resend_all
  # it's needed so the request being resend doesn't create duplicate queue
  def send(skip_failed_requests_processing = false)
    http = Net::HTTP::Proxy(
      PostageApp.configuration.proxy_host,
      PostageApp.configuration.proxy_port,
      PostageApp.configuration.proxy_user,
      PostageApp.configuration.proxy_pass
    ).new(url.host, url.port)
    
    http.read_timeout = PostageApp.configuration.http_read_timeout
    http.open_timeout = PostageApp.configuration.http_open_timeout
    http.use_ssl      = PostageApp.configuration.secure?
    
    PostageApp.logger.info(self)
    
    http_response = begin
      http.post(
        url.path, 
        self.arguments_to_send.to_json, 
        HEADERS.merge('User-Agent' => "PostageApp-RubyGem #{PostageApp::VERSION} (Ruby #{RUBY_VERSION}, #{PostageApp.configuration.framework})")
      )
    rescue TimeoutError
      nil
    end
    
    response = PostageApp::Response.new(http_response)
    
    PostageApp.logger.info(response)
    
    unless skip_failed_requests_processing
      response.fail?? PostageApp::FailedRequest.store(self) : PostageApp::FailedRequest.resend_all
    end
    
    response
  end
  
  # URL of the where PostageApp::Request will be directed at
  def url
    URI.parse("#{PostageApp.configuration.url}/v.#{API_VERSION}/#{self.method}.json")
  end
  
  # Unique ID of the request
  def uid(reload = false)
    @uid = nil if reload
    @uid ||= Digest::SHA1.hexdigest("#{Time.now.to_f}#{self.arguments}")
  end
  
  # Arguments need to be appended with some some stuff before it's ready to be send out
  def arguments_to_send
    hash = { 'uid' => self.uid, 'api_key' => PostageApp.configuration.api_key }
    
    if !self.arguments.nil? && !self.arguments.empty?
      if !PostageApp.configuration.recipient_override.nil? && self.method.to_sym == :send_message
        self.arguments.merge!('recipient_override' => PostageApp.configuration.recipient_override)
      end
      hash.merge!('arguments' => self.arguments.stringify_keys!) 
    end
    hash
  end
  
end