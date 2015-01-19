module WithEnvironment
  def with_environment(env)
    prev_env = { }

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
