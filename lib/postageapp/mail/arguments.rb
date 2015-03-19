require 'set'

class PostageApp::Mail::Arguments
  HEADERS_IGNORED = Set.new(%w[
    Content-Type
  ]).freeze

  def initialize(mail)
    @mail = mail
  end

  def extract(arguments = nil)
    arguments ||= { }
    arguments['content'] ||= { }
    arguments['headers'] ||= { }

    if (@mail.multipart?)
      @mail.parts.each do |part|
        add_part(arguments, part)
      end
    else
      add_part(arguments, @mail)
    end

    _headers = arguments['headers']
    @mail.header.fields.each do |field|
      next if (HEADERS_IGNORED.include?(field.name))

      _headers[field.name] = field.value
    end

    if (@mail.has_attachments?)
      @mail.attachments.each do |attachment|
        # ...
      end
    end

    [ :send_message, arguments ]
  end

protected
  def add_part(arguments, part)
    case (part.content_type.to_s.split(/\s*;/).first)
    when 'text/html'
      arguments['content']['text/html'] = part.body.to_s
    when 'text/plain', nil
      arguments['content']['text/plain'] = part.body.to_s
    else
      # ...
    end
  end
end
