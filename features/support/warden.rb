Warden.test_mode!
World Warden::Test::Helpers

Before do
  @current_user = FactoryGirl.create(:user)
  login_as(@current_user, :scope => :user)
end

After do
  Warden.test_reset!
end