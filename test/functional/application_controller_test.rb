require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  # should_helper :all
  should_have_helper_method :logged_in?, :admin_logged_in?, :current_user_session, :current_user
  should_protect_from_forgery

  should_filter_params :password, :confirm_password, :password_confirmation, :creditcard
  
  context "#logged_in?" do
    should "return true if there is a user session" do
      @the_user = User.generate!
@the_user.activate!

      UserSession.create(@the_user)
      assert controller.logged_in?
    end
    
    should "return false if there is no session" do
      assert !controller.logged_in?
    end
  end
  
  context "#admin_logged_in?" do
    should "return true if there is a user session for an admin" do
      @the_user = User.generate!
@the_user.activate!

      @the_user.roles << "admin"
      UserSession.create(@the_user)
      assert controller.admin_logged_in?
    end
    
    should "return false if there is a user session for a non-admin" do
      @the_user = User.generate!
@the_user.activate!

      @the_user.roles = []
      UserSession.create(@the_user)
      assert !controller.admin_logged_in?
    end
    
    should "return false if there is no session" do
      assert !controller.admin_logged_in?
    end
  end
  
  # TODO: Test filter methods
end
