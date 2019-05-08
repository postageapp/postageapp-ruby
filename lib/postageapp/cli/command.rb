require 'optparse'

class PostageApp::CLI::Command
  class APICallError < StandardError
  end

  class MissingArguments < StandardError
  end

  def self.defined
    @defined ||= { }
  end

  def self.define(command_name, &block)
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

  def argument(name, optional: false, type: String, description: nil)
    @argument[name] = {
      optional: optional,
      type: String,
      description: description
    }
  end

  def parse!(*args)
    arguments = { }

    op = OptionParser.new do |parser|
      parser.banner = "Usage: postageapp #{@command_name} [options]"

      @argument.each do |name, attributes|
        parser.on("--#{name} VALUE", "#{attributes[:description]} (#{attributes[:optional] ? 'optional' : 'required'})") do |v|
          arguments[name] = v
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

    response = PostageApp::Request.new(@command_name, arguments).send

    case (response.status)
    when "200"
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
  require command
end
