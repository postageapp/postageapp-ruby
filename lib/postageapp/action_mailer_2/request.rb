# A set of methods that are useful when request needs to behave as TMail::Mail
class PostageApp::Request
  
  def to
    self.arguments_to_send.dig('arguments', 'recipients')
  end
  
  def from
    self.arguments_to_send.dig('arguments', 'headers', 'from')
  end
  
  def subject
    self.arguments_to_send.dig('arguments', 'headers', 'subject')
  end
  
  def body
    self.arguments_to_send.dig('arguments', 'content')
  end
  
end