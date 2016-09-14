class PostageApp::Logger < ::Logger
  # == Instance Methods =====================================================
  
  def format_message(severity, datetime, progname, msg)
    "[%s] %s\n" % [
      datetime.strftime('%m/%d/%Y %H:%M:%S %Z'),
      case (msg)
      when PostageApp::Request
        "REQUEST [#{msg.url}]\n #{msg.arguments_to_send.to_json}"
      when PostageApp::Response
        "RESPONSE [#{msg.status} #{msg.uid} #{msg.message}]\n #{msg.data.to_json}"
      else
        msg
      end
    ]
  end
end
