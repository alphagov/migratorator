GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = 'abcdefghjasndjkasnd'
  config.oauth_secret = 'secret'
  config.oauth_root_url = Plek.current.find("authentication")
end
# Omniauth can't figure out the hostname because it's being proxied through nginx
OmniAuth.config.full_host = "http://migratorator.dev.gov.uk"