PostageApp::CLI::Command.define do
  argument :'no-header',
    optional: true,
    boolean: true,
    desc: 'An identifier to refer to this mailbox on subsequent API calls'

  argument :markdown,
    optional: true,
    boolean: true,
    desc: 'Emit markdown formatted description of variables'

  perform do |arguments|
    if (arguments[:markdown])
      PostageApp::Configuration.params.each do |param, config|
        case (default = config[:default])
        when Proc
          default = default.call
        end

        puts '* `%s`: %s (%s)' % [
          param,
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

        config[:aliases]&.each do |param_alias|
          puts '* `%s`: Alias for `%s`' % [
            param_alias,
            param
          ]
        end
      end
    else
      unless (arguments[:'no-header'])
        puts '%-40s %s' % [ 'Variable', 'Description' ]
        puts '-' * 78
      end
  
      PostageApp::Configuration.params.each do |param, config|
        case (default = config[:default])
        when Proc
          default = default.call
        end

        puts '%-40s %s (%s)' % [
          param,
          config[:desc],
          case (config[:required])
          when String
            'required %s' % config[:required]
          when true
            'required'
          else
            default ? 'default: %s' % default : 'optional'
          end
        ]

        config[:aliases]&.each do |param_alias|
          puts '%-40s Alias for %s' % [
            param_alias,
            param
          ]
        end
      end
    end
  end
end
