require File.join(File.dirname(__FILE__), '..', 'test_helper')

class UserCanLoginTest < ActionController::IntegrationTest

  context 'an existing user' do
    setup do
      @the_user = User.generate!
@the_user.activate!

    end

    should 'be able to login with valid id and password' do
      visit signin_path

      fill_in 'Sign In', :with => @the_user.login
      fill_in 'Password', :with => @the_user.password

      click_button 'Sign In'

      assert_equal '/', path
      assert_contain I18n.t('flash.user_sessions.create.notice')
    end
  end
end
