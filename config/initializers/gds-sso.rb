GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = 'abcdefghjasndjkasndmigratorator'
  config.oauth_secret = 'secret'
  config.oauth_root_url = Plek.current.find("authentication")
  config.default_scope = "Migratorator"
end
