class PostageApp::Request
  
  API_VERSION = '1.0'
  
  HEADERS = {
    'Content-type'            => 'application/json',
    'Accept'                  => 'text/json, application/json',
    'User-Agent'              => "PostageApp RubyGem v.#{PostageApp::VERSION}"
  }
  
  # The API method being called (example: send_message)
  # This controls the url of the request (example: https://api.postageapp.com/v.1.0/send_message.json)
  attr_accessor :method
  
  # A list of arguments in a Hash format passed along with the request
  attr_accessor :arguments
  
  # The PostageApp::Response object that comes after a successful request
  attr_accessor :response
  
  def initialize(method, arguments = {})
    @method     = method
    @arguments  = arguments
  end
  
  def send
    http = Net::HTTP::Proxy(
      PostageApp.configuration.proxy_host,
      PostageApp.configuration.proxy_port,
      PostageApp.configuration.proxy_user,
      PostageApp.configuration.proxy_pass
    ).new(url.host, url.port)
    
    http.read_timeout = PostageApp.configuration.http_read_timeout
    http.open_timeout = PostageApp.configuration.http_open_timeout
    http.use_ssl      = PostageApp.configuration.secure?
    
    http_response = begin
      http.post(url.path, self.arguments_to_send.to_json, HEADERS)
    rescue TimeoutError
      nil
    end
    
    PostageApp::Response.new(http_response)
  end
  
  # URL of the where PostageApp::Request will be directed at
  def url
    URI.parse("#{PostageApp.configuration.url}/v.#{API_VERSION}/#{self.method}.json")
  end
  
  # Unique ID of the request
  def uid(reload = false)
    @uid = nil if reload
    @uid ||= Digest::MD5.hexdigest("#{Time.now.to_f}#{self.arguments}")
  end
  
  # Arguments need to be appended with some some stuff before it's ready to be send out
  def arguments_to_send
    hash = { 'uid' => self.uid, 'api_key'  => PostageApp.configuration.api_key }
    
    if !self.arguments.nil? && !self.arguments.empty?
      if PostageApp.configuration.recipient_override.present? && self.method.to_sym == :send_message
        self.arguments.merge!('recipient_override' => PostageApp.configuration.recipient_override)
      end
      hash.merge!('arguments' => self.arguments.stringify_keys!) 
    end
    hash
  end
  
end