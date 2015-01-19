#!/usr/bin/env ruby

require 'yaml'

require File.expand_path('with_environment', File.dirname(__FILE__))

class TravisTest
  extend WithEnvironment

  ENV_VARIABLE = {
    :rvm => "RBENV_VERSION",
    :gemfile => "BUNDLE_GEMFILE"
  }

  def self.bash_env(env)
    env.collect do |key, value|
      variable = ENV_VARIABLE[key]

      variable ? '%s=%s' % [ variable, value ] : nil
    end.compact.join(' ')
  end

  def self.env_expanded(env)
    Hash[
      env.collect do |key, value|
        [ ENV_VARIABLE[key], value ]
      end
    ]
  end

  def self.shell_command!(args, env)
    commands = args.collect do |s|
      s % env
    end

    env_expanded(env).each do |key, value|
      puts 'export %s=%s' % [ key, value ]
    end
    puts(commands.join(' && '))
    
    with_environment(env_expanded(env)) do
      result = system(commands.join(' && '))

      yield(result) if (block_given?)

      result
    end
  end

  def self.install_versions!
    travis_test = self.new

    travis_test.matrix.collect do |entry|
      {
        :rvm => entry[:rvm]
      }
    end.uniq.each do |entry|
      puts "Ruby %{rvm}" % entry

      shell_command!(
        [
          "rbenv install %{version}",
          "gem install bundler"
        ],
        entry
      )
    end
  end

  def self.validate_ruby_versions!
    travis_test = self.new

    versions = { }

    travis_test.matrix.each do |entry|
      next if (versions[entry[:rvm]])

      versions[entry[:rvm]] = true

      shell_command!(
        [
          "ruby -e 'puts RUBY_VERSION'"
        ],
        entry
      )
    end
  end

  def self.gemfile_lock_remove!(path)
    path = path + '.lock'

    if (File.exist?(path))
      File.unlink(path)
    end

  rescue Errno::ENOENT
    # Already removed for some reason? Ignore.
  end

  def self.run!
    travis_test = self.new

    results = { }

    travis_test.matrix.each do |entry|
      puts "RBENV_VERSION=%{rvm} BUNDLE_GEMFILE=%{gemfile}" % entry

      gemfile_lock_remove!(entry[:gemfile])

      shell_command!(
        [
          "bundle install --quiet",
          "rake test"
        ],
        entry
      ) do |code|
        results[entry] = code
      end
    end

    puts '%-20s %-24s %-6s' % [ 'Ruby', 'Gemfile', 'Status' ]
    puts '-' * 78

    results.each do |entry, code|
      puts '%-20s %-24s %-6s' % [
        entry[:rvm],
        File.basename(entry[:gemfile]).sub(/\AGemfile\./,''),
        code
      ]
    end
  end

  def travis_config_path
    @travis_config_path ||= File.expand_path('../.travis.yml', File.dirname(__FILE__))
  end

  def travis_config
    @travis_config ||= YAML.load(File.open(travis_config_path))
  end

  def gemfiles
    travis_config['gemfile']
  end

  def ruby_versions
    travis_config['rvm']
  end

  def matrix_exclusions
    travis_config['matrix']['exclude'].collect do |entry|
      {
        :rvm => entry['rvm'],
        :gemfile => entry['gemfile']
      }
    end
  end

  def matrix
    ruby_versions.flat_map do |version|
      gemfiles.collect do |gemfile|
        {
          :rvm => version,
          :gemfile => gemfile
        }
      end
    end - matrix_exclusions
  end
end
