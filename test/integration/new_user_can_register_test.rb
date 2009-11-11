require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NewUserCanRegisterTest < ActionController::IntegrationTest
  context 'a site visitor' do

    should 'be able to create a new account' do
      visit root_path
      click_link 'Sign Up'

      assert_equal new_account_path, path
      assert_contain 'Sign Up'

      fill_in 'Email', :with => 'francis@example.com'

      click_button 'Sign Up'

      assert_equal "/account", path
      assert_contain I18n.t("flash.accounts.create.notice")
    end
  end
end
