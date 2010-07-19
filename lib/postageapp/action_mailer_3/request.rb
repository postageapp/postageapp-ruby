# A set of methods that are useful when request needs to behave as Mail
class PostageApp::Request
  
  # a pile of accessors so we can just ignore them later
  attr_accessor :delivery_handler,
                :delivery_method,
                :perform_deliveries,
                :raise_delivery_errors,
                :charset
  
  def deliver
    raise 'deliver this thing!'
  end
  
  def delivery_method(method = nil, settings = {})
    
  end
  
end