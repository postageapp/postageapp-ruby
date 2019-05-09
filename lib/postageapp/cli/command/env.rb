PostageApp::CLI::Command.define do
  argument :'no-header',
    optional: true,
    boolean: true,
    desc: 'Suppress display of header'

  argument :markdown,
    optional: true,
    boolean: true,
    desc: 'Emit markdown formatted description of variables'

  perform do |arguments|
    if (arguments[:markdown])
      PostageApp::Configuration.params.each do |param, config|
        config[:env_vars]&.each_with_index do |var, i|
          case (i)
          when 0
            case (default = config[:default])
            when Proc
              default = default.call
            end

            puts '* `%s`: %s (%s)' % [
              var,
              config[:desc],
              case (config[:required])
              when String
                'required %s' % config[:required]
              when true
                'required'
              else
                default ? 'default: `%s`' % default : 'optional'
              end
            ]
          else
            puts '* `%s`: Alias for `%s`' % [
              var,
              config[:env_vars][0]
            ]
          end
        end
      end
    else
      unless (arguments[:'no-header'])
        puts '%-40s %s' % [ 'Variable', 'Setting' ]
        puts '-' * 78
      end
  
      PostageApp::Configuration.params.each do |param, config|
        config[:env_vars]&.each do |var|
          puts '%-40s %s' % [
            var, ENV[var]
          ]
        end
      end
    end
  end
end
