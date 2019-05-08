module PostageApp::CLI
  class UnknownCommand < StandardError
  end

  def self.parse!(command_name, *args)
    if (command = PostageApp::CLI::Command.defined[command_name.to_sym])
      command.parse!(*args)
    else
      raise UnknownCommand, "The command #{command_name.inspect} is not known."
    end
  end
end

require_relative './cli/command'
