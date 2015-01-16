#!/usr/bin/env ruby

require 'yaml'

class TravisTest
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

  def self.merge_env!(env)
    env.each do |key, value|
      if (variable = ENV_VARIABLE[key])
        ENV[variable] = value
      end
    end
  end

  def self.shell_command!(args, env)
    commands = args.collect do |s|
      s % env
    end

    puts(commands.collect { |c| [ bash_env(env), c ].join(' ') }.join(' && '))
    
    merge_env!(env)
    system(commands.join(' && '))
  end

  def self.install_versions!
    @travis_test = self.new

    @travis_test.matrix.collect do |entry|
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

  def self.run!
    @travis_test = self.new

    @travis_test.matrix.each do |entry|
      puts "RBENV_VERSION=%{rvm} BUNDLE_GEMFILE=%{gemfile}" % entry

      shell_command!(
        [
          "bundle install",
          "rake test"
        ],
        entry
      )
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
