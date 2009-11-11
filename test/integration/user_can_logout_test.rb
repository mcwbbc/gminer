require File.join(File.dirname(__FILE__), '..', 'test_helper')

class UserCanLogoutTest < ActionController::IntegrationTest

  context 'a logged-in user' do
    setup do
      @the_user = User.generate!
@the_user.activate!

      visit login_path
      fill_in 'Sign In', :with => @the_user.login
      fill_in 'Password', :with => @the_user.password
      click_button 'Sign In'
    end

    should 'be able to log out' do
      visit root_path

      click_link "Sign out"

      assert_equal new_user_session_path, path
      assert_contain I18n.t('flash.user_sessions.destroy.notice')
    end
  end
end
