require "octorepl/version"

require 'octokit'
require 'optparse'
require 'pry'
require 'yaml'

module Octorepl
  class Config
    def self.attr_config(*names)
      names.each do |name|
        define_method(name) { merged.fetch(name) }
      end
    end

    attr_config :host, :protocol, :user, :token, :ssl_verify
    alias_method :verify_ssl?, :ssl_verify

    def initialize
      @defaults = {
        host: 'github.com',
        protocol: 'https',
        ssl_verify: true,
      }
      @learned  = {}
    end

    def enterprise?
      self.host != @defaults.fetch(:host)
    end

    def web_base
      self.enterprise? ? "#{self.protocol}://#{self.host}" : "https://github.com"
    end

    def api_base
      self.enterprise? ? "#{self.protocol}://#{self.host}/api/v3" : "https://api.github.com/v3"
    end

    def learn(k, v)
      tap {|*| @learned[k] = v }
    end

    private \
      def merged
        @defaults.merge(@learned)
      end
  end

  class Context
    attr_reader :octokit

    def initialize(config)
      if config.enterprise?
        Octokit.configure do |c|
          c.api_endpoint = config.api_base
          c.web_endpoint = config.web_base
        end
      end

      if ! config.verify_ssl?
        Octokit.configure do |c|
          c.connection_options = { ssl: { verify: false } }
        end
      end

      login        = config.user
      access_token = config.token
      @octokit = Octokit::Client.new(login: login, access_token: access_token)
    end
  end

  def self.start(argv)
    config = Octorepl::Config.new
    OptionParser.new {|o|
      o.on('-h', '--host HOST') {|v| config.learn(:host, v) }
      o.on('--disable-ssl-verify') {|v| config.learn(:ssl_verify, !v) }
    }.parse!(argv)

    hub_config = YAML.load_file(File.expand_path('~/.config/hub'))
    host_config = hub_config.fetch(config.host).first

    config.learn(:protocol, host_config['protocol']) if host_config.has_key?('protocol')
    config.learn(:user, host_config.fetch('user'))
    config.learn(:token, host_config.fetch('oauth_token'))

    ctx = Octorepl::Context.new(config)
    ctx.pry
  end
end
