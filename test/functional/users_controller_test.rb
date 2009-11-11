require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  should_have_before_filter :require_no_user, :only => [:new, :create]
  should_have_before_filter :require_user, :only => [:show, :edit, :update]
  should_have_before_filter :admin_required, :only => [:index, :destroy]


  context "routing" do
    should_route :get, "/users", :action=>"index", :controller=>"users"
    should_route :post, "/users", :action=>"create", :controller=>"users"
    should_route :get, "/users/new", :action=>"new", :controller=>"users"
    should_route :get, "/users/1/edit", :action=>"edit", :controller=>"users", :id => 1
    should_route :get, "/users/1", :action=>"show", :controller=>"users", :id => 1
    should_route :put, "/users/1", :action=>"update", :controller=>"users", :id => 1
    should_route :delete, "/users/1", :action=>"destroy", :controller=>"users", :id => 1

    context "named routes" do
      setup do
        get :index
      end

      should "generate users_path" do
        assert_equal "/users", users_path
      end
      should "generate user_path" do
        assert_equal "/users/1", user_path(1)
      end
      should "generate new_user_path" do
        assert_equal "/users/new", new_user_path
      end
      should "generate edit_user_path" do
        assert_equal "/users/1/edit", edit_user_path(1)
      end
    end
  end

  context "on GET to :index" do
    setup do
      stub(controller).admin_required{ true }
      @the_user = User.generate!
      stub(User).all{ [@the_user] }
      get :index
    end

    should_assign_to(:users) { [@the_user] }
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
  end

  context "on GET to :new" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user = User.generate!
      stub(User).new{ @the_user }
      get :new
    end

    should_assign_to(:user) { @the_user }
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user = User.generate!
      stub(User).new{ @the_user }
    end

    context "with successful creation" do
      setup do
        stub(@the_user).signup!{ true }
        post :create, :user => { :login => "bobby", :password => "bobby", :password_confirmation => "bobby" }
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.accounts.create.notice")
      should_redirect_to("the root url") { root_url }
    end

    context "with failed creation" do
      setup do
        stub(@the_user).signup!{ false }
        post :create, :user => { :login => "bobby", :password => "bobby", :password_confirmation => "bobby" }
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template :new
    end
  end

  context "with a regular user" do
    # TODO: insert checks that user can only get to their own stuff, even with spoofed URLs
  end

  context "with an admin user" do
    setup do
      @admin_user = User.generate!
      @admin_user.activate!
      @admin_user.roles << "admin"
      UserSession.create(@admin_user)
      @the_user = User.generate!
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @the_user.id
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template :show
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @the_user.id
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template :edit
    end

    context "on DELETE to :destroy" do
      setup do
        delete :destroy, :id => @the_user.id
      end

      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.users.destroy.notice")
      should_redirect_to("the users page") { users_path }
    end
  end
end
