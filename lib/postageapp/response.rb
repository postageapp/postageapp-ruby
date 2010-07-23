class PostageApp::Response
  
  # The UID should match the Request's UID. If Request didn't provide with one
  # PostageApp service should generate it for the Response
  attr_reader :uid
  
  # The status of the response in string format (like: ok, bad_request)
  # Will be set to +fail+ if Request times out
  attr_reader :status
  
  # The message of the response. Could be used as an error explanation.
  attr_reader :message
  
  # The data payload of the response. This is usually the return value of the
  # request we're looking for
  attr_reader :data
  
  # Takes in Net::HTTPResponse object as the attribute.
  # If something goes wrong Response will be thought of as failed
  def initialize(http_response)
    hash = JSON::parse(http_response.body)
    @status   = hash['response']['status']
    @uid      = hash['response']['uid']
    @message  = hash['response']['message']
    @data     = hash['data']
  rescue
    @status   = 'fail'
  end
  
  # Little helper that checks for the Response status
  #   => @response.ok?
  #   >> true
  #   => @response.fail?
  #   >> false
  def method_missing(method)
    /.*?\?$/.match(method.to_s) ? "#{self.status}?" == method.to_s : super(method)
  end
  
end