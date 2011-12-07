require 'omniauth-openid'
require 'gapps_openid'

module OpenID
  # Because gapps_openid changes the discovery order
  # (looking first for Google Apps, then anything else),
  # we need to monkeypatch it to make it play nicely
  # with others.
  def self.discover(uri)
    discovered = self.default_discover(uri)

    if discovered.last.empty?
      info = discover_google_apps(uri)
      return info if info
    end

    return discovered
  rescue OpenID::DiscoveryFailure => e
    Rails.logger.error "OpenId::DiscoveryFailure:  #{e.inspect}"
    info = discover_google_apps(uri)

    if info.nil?
      raise e
    else
      return info
    end
  end

  def self.discover_google_apps(uri)
    discovery = GoogleDiscovery.new
    discovery.perform_discovery(uri)
  end
end

module OmniAuth
  module Strategies
    class GoogleApps < OmniAuth::Strategies::OpenID
      def initialize(app, store = nil, options = {}, &block)
        options[:name] ||= 'google_apps'
        
        hash = {
          app: app,
          store: store,
          options: options
        }
        Rails.logger.debug ">>>>>>>>> hash = #{hash.inspect}"
        
        super(app, options, &block)
      end

      def get_identifier
        OmniAuth::Form.build(:title => 'Google Apps Authentication') do
          label_field('Google Apps Domain', 'domain')
          input_field('url', 'domain')
        end.to_response
      end

      def identifier
        id = options[:domain] || request['domain']
      end
    end
  end
end