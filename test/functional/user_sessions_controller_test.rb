require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  should_have_before_filter :require_no_user, :only => [:new, :create]
  should_have_before_filter :require_user, :only => :destroy

  context "routing" do
    should_route :get, "/account/new", :controller => "accounts", :action => "new"
    should_route :post, "/account", :action=>"create", :controller=>"accounts"
    should_route :delete, "/user_session", :action=>"destroy", :controller=>"user_sessions"
    # TODO: Figure out what to do about these
    # should_route :get, "/signin", :action=>"new", :controller=>"user_sessions"
    # should_route :get, "/signout", :action=>"destroy", :controller=>"user_sessions"
    
    context "named routes" do
      setup do
        get :new
      end
      
      should "generate user_session_path" do
        assert_equal "/user_session", user_session_path
      end
      should "generate new_user_session_path" do
        assert_equal "/user_session/new", new_user_session_path
      end
      should "generate signin_path" do
        assert_equal "/signin", signin_path
      end
      should "generate signout_path" do
        assert_equal "/signout", signout_path
      end
    end
  end

  context "on GET to :new" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user_session = UserSession.new
      stub(UserSession).new{ @the_user_session }
      get :new
    end
    
    should_assign_to(:user_session) { @the_user_session }
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user_session = UserSession.new
      stub(UserSession).new{ @the_user_session }
    end
    
    context "with successful creation" do
      setup do
        stub(@the_user_session).save{ true }
        post :create, :user_session => { :login => "bobby", :password => "bobby" }
      end

      should_assign_to(:user_session) { @the_user_session }
      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.user_sessions.create.notice")
      should_redirect_to("the root url") { root_url }
    end
    
    context "with failed creation" do
      setup do
        stub(@the_user_session).save{ false }
        post :create, :user_session => { :login => "bobby", :password => "bobby" }
      end
      
      should_assign_to(:user_session) { @the_user_session }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template :new
    end
  end
  
  context "on DELETE to :destroy" do
    setup do
      @the_user = User.generate!
@the_user.activate!

      UserSession.create(@the_user)
      delete :destroy
    end
    
    should_respond_with :redirect
    should_set_the_flash_to I18n.t("flash.user_sessions.destroy.notice")
    should_redirect_to("the login page") { new_user_session_url }
  end
  
end
