module WithEnvironment
  def with_environment(env)
    prev_env = {
      'PATH' => ENV['PATH']
    }

    # Remove rbenv version specific paths to restore environment to normal,
    # non-versioned state.
    ENV['PATH'] = ENV['PATH'].split(/:/).reject do |path|
      path.match(%r[/\.rbenv/versions/])
    end.join(':')

    env.each do |key, value|
      key = key.to_s

      prev_env[key] = ENV[key]
      ENV[key] = value
    end

    yield

  ensure
    prev_env.each do |key, value|
      ENV[key] = value
    end
  end
end
