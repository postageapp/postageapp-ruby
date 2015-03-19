class PostageApp::Configuration
  # +true+ for https, +false+ for http connections (default: is +true+)
  attr_accessor :secure
  
  # The protocol used to connect to the service (default: 'https' for secure 
  # and 'http' for insecure connections)
  attr_accessor :protocol
  
  # The host to connect to (default: 'api.postageapp.com')
  attr_accessor :host
  
  # The port on which PostageApp service runs (default: 443 for secure, 80 for 
  # insecure connections)
  attr_writer :port
  
  # The hostname of the proxy server (if using a proxy)
  attr_accessor :proxy_host
  
  # The port of the proxy server (if using proxy)
  attr_accessor :proxy_port
  
  # The username for the proxy server (if using proxy)
  attr_accessor :proxy_user
  
  # The password for the proxy server (if using proxy)
  attr_accessor :proxy_pass
  
  # The HTTP open timeout in seconds (defaults to 2).
  attr_accessor :http_open_timeout
  
  # The HTTP read timeout in seconds (defaults to 5).
  attr_accessor :http_read_timeout
  
  # The email address that all send_message method should address
  # all messages while overriding original addresses
  attr_accessor :recipient_override
  
  # A list of API method names payloads of which are captured and resent
  # in case of service unavailability
  attr_accessor :requests_to_resend
  
  # The file path of the project. This is where logs and failed requests
  # can be stored
  attr_accessor :project_root
  
  # The framework PostageApp gem runs in
  attr_accessor :framework
  
  # Environment gem is running in
  attr_accessor :environment
  
  # The logger used by this gem
  attr_accessor :logger
  
  def initialize
    @secure = true
    @host = 'api.postageapp.com'
    @http_open_timeout = 5
    @http_read_timeout = 10
    @requests_to_resend = %w( send_message )
    @framework = 'undefined framework'
    @environment = 'production'
  end
  
  alias_method :secure?, :secure
  
  # Assign which API key is used to make API calls. Can also be specified
  # using the `POSTAGEAPP_API_KEY` environment variable.
  def api_key=(key)
    @api_key = key
  end
  
  # Returns the API key used to make API calls. Can be specified as the
  # `POSTAGEAPP_API_KEY` environment variable.
  def api_key
    @api_key ||= ENV['POSTAGEAPP_API_KEY']
  end
  
  # Returns the HTTP protocol used to make API calls
  def protocol
    @protocol ||= (secure? ? 'https' : 'http')
  end
  
  # Returns the port used to make API calls
  def port
    @port ||= (secure? ? 443 : 80)
  end
  
  # Returns the endpoint URL to make API calls
  def url
    "#{self.protocol}://#{self.host}:#{self.port}"
  end

  # Returns a properly config
  def http
    http = Net::HTTP::Proxy(
      self.proxy_host,
      self.proxy_port,
      self.proxy_user,
      self.proxy_pass
    ).new(self.host, self.port)
    
    http.read_timeout = self.http_read_timeout
    http.open_timeout = self.http_open_timeout
    http.use_ssl = self.secure?

    http
  end
end
