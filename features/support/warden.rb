Warden.test_mode!
World Warden::Test::Helpers

Before do
  @current_user = User.create!(:name => "Test")
  login_as(@current_user, :scope => :user)
end

After do
  Warden.test_reset!
end