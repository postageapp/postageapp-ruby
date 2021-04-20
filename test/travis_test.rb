#!/usr/bin/env ruby

require 'yaml'
require 'open3'
require 'shellwords'

require_relative './with_environment'

class TravisTest
  extend WithEnvironment

  ENV_VARIABLE = {
    rvm: 'RBENV_VERSION',
    version: 'RBENV_VERSION',
    gemfile: 'BUNDLE_GEMFILE'
  }

  def self.bash_env(env)
    env.collect do |key, value|
      variable = ENV_VARIABLE[key]

      variable ? '%s=%s' % [ variable, value ] : nil
    end.compact.join(' ')
  end

  def self.environment(env)
    env.map do |key, value|
      [ ENV_VARIABLE[key], value ]
    end.to_h
  end

  def self.shell!(commands, env)
    commands = commands.collect do |s|
      s % env
    end

    shell_cmds = [
      'eval "$(rbenv init -)"',
      'set -e',
      *commands
    ].join('; ')

    # p environment(env)
    # puts shell_cmds

    Open3.popen3(
      environment(env),
      shell_cmds
    ) do |_sin, sout, serr, proc|
      status = proc.value.exitstatus

      yield(status) if (block_given?)

      status.tap do |status|
        if (status != 0)
          $stderr.puts 'Error code: %d' % status
        end

        if (status != 0 or ENV['VERBOSE'])
          puts sout.read
          puts serr.read
        end
      end
    end
  end

  def self.install_versions!
    travis_test = self.new

    travis_test.matrix.collect do |entry|
      {
        rvm: entry[:rvm]
      }
    end.uniq.each do |entry|
      puts 'Ruby %{rvm}' % entry

      shell!(
        [
          'rbenv install %{version}',
          'gem install bundler'
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

      shell!(
        [
          %q[ruby -e 'puts RUBY_VERSION']
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
      puts 'RBENV_VERSION=%{rvm} BUNDLE_GEMFILE=%{gemfile}' % entry

      gemfile_lock_remove!(entry[:gemfile])

      shell!(
        [
          'gem install bundler --no-doc',
          'bundle install --quiet',
          'bundle exec rake test'
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
        code ? 'Pass' : 'Fail'
      ]
    end
  end

  def travis_config_path
    @travis_config_path ||= File.expand_path('../.travis.yml', __dir__)
  end

  def travis_config
    @travis_config ||= YAML.load(File.open(travis_config_path))
  end

  def gemfiles
    travis_config['gemfile']
  end

  def ruby_versions
    travis_config['rvm'].sort
  end

  def matrix_exclusions
    travis_config.dig('matrix', 'exclude')&.collect do |entry|
      {
        rvm: entry['rvm'],
        gemfile: entry['gemfile']
      }
    end or [ ]
  end

  def matrix
    ruby_versions.flat_map do |version|
      gemfiles.collect do |gemfile|
        {
          rvm: version,
          gemfile: gemfile
        }
      end
    end - matrix_exclusions
  end
end
