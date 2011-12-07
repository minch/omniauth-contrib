require "omniauth-contrib/version"
require "omniauth"

module OmniAuth
  module Strategies
    autoload :VKontakte,  'omniauth/strategies/vkontakte'
    autoload :GoogleApps,  'omniauth/strategies/google_apps'
  end
end

OmniAuth.config.add_camelization 'vkontakte', 'VKontakte'
