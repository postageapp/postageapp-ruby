require 'set'

# This class decomposes a Mail::Message into a PostageApp API call that
# produces the same result when sent.

class PostageApp::Mail::Arguments
  # Certain headers need to be ignored since they are generated internally.
  HEADERS_IGNORED = Set.new(%w[
    Content-Type
    To
  ]).freeze

  # Creates a new instance with the given Mail::Message binding.
  def initialize(mail)
    @mail = mail
  end

  # Returns the extracted arguments. If a pre-existing arguments has is
  # supplied, arguments are injected into that.
  def extract(arguments = nil)
    arguments ||= { }
    arguments['content'] ||= { }
    arguments['headers'] ||= { }

    arguments['recipients'] = @mail.to

    if (@mail.multipart?)
      @mail.parts.each do |part|
        if (part.content_disposition)
          add_attachment(arguments, part)
        else
          add_part(arguments, part)
        end
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
        add_attachment(arguments, attachment)
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
      # Unknown type.
    end
  end

  def add_attachment(arguments, part)
    arguments['attachments'] ||= { }

    arguments['attachments'][part.filename] = {
      'content' => Base64.encode64(part.body.to_s),
      'content_type' => part.content_type
    }
  end
end
