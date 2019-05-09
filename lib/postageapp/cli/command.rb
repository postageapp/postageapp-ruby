require 'optparse'

class PostageApp::CLI::Command
  class APICallError < StandardError
  end

  class MissingArguments < StandardError
  end

  def self.defined
    @defined ||= { }
  end

  def self.define(command_name = nil, &block)
    command_name ||= $command_name
    command = self.defined[command_name] = new(command_name)

    command.instance_eval(&block) if (block_given?)
  end

  def initialize(command_name)
    @command_name = command_name
    @api_key_context = :project
    @argument = { }
  end

  def api_key(context)
    @api_key_context = context
  end

  def argument(name, optional: false, type: String, desc: nil, boolean: false)
    @argument[name] = {
      optional: optional,
      type: String,
      desc: desc,
      boolean: boolean
    }
  end

  def perform(&block)
    @perform = block
  end

  def parse!(*args)
    arguments = { }

    op = OptionParser.new do |parser|
      parser.banner = "Usage: postageapp #{@command_name} [options]"

      @argument.each do |name, attributes|
        if (attributes[:boolean])
          parser.on("--#{name}", attributes[:desc]) do
            arguments[name] = true
          end
        else
          parser.on("--#{name} VALUE", "#{attributes[:desc]} (#{attributes[:optional] ? 'optional' : 'required'})") do |v|
            arguments[name] = v
          end
        end
      end
    end
    
    op.parse!(args)

    missing = @argument.select do |name, attributes|
      !attributes[:optional] && arguments[name].nil?
    end.keys

    if (missing.any?)
      $stderr.puts("Error: missing options #{missing.join(', ')}")

      puts op.help

      raise MissingArguments
    end

    case (@api_key_context)
    when :account
      arguments['api_key'] = PostageApp.configuration.account_api_key
    end

    case (@perform&.arity)
    when 1
      return @perform.call(arguments)
    when 0
      return @perform.call
    end

    response = PostageApp::Request.new(@command_name, arguments).send

    case (response.status)
    when "ok"
      puts JSON.pretty_generate(response.data)
    else
      $stderr.puts("Received error: #{response.status}")

      if (response.message)
        $stderr.puts('  ' + response.message)
      end

      raise APICallError
    end
  end
end

Dir.glob(File.expand_path('./command/*.rb', __dir__)) do |command|
  $command_name = File.basename(command, '.rb').to_sym

  require command
end
