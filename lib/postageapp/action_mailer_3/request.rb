# A set of methods that are useful when request needs to behave as Mail
class PostageApp::Request
  
  attr_accessor :delivery_handler,
                :delivery_method,
                :perform_deliveries,
                :raise_delivery_errors
  
  def deliver
    raise 'deliver this thing!'
  end
  
  def delivery_method(method = nil, settings = {})
    
  end
  
end