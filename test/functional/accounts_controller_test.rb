require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  should_have_before_filter :require_no_user, :only => [:new, :create]
  should_have_before_filter :require_user, :only => [:show, :edit, :update]

  context "routing" do
    should_route :get, "/account/new", :controller => "accounts", :action => "new"
    should_route :get, "/account/edit", :action=>"edit", :controller=>"accounts"
    should_route :get, "/account", :action=>"show", :controller=>"accounts"
    should_route :put, "/account", :action=>"update", :controller=>"accounts"
    should_route :post, "/account", :action=>"create", :controller=>"accounts"
    # TODO: Figure out what to do about this
    # should_route :get, "/signup", :action=>"new", :controller=>"accounts"

    context "named routes" do
      setup do
        get :show
      end

      should "generate account_path" do
        assert_equal "/account", account_path
      end
      should "generate new_account_path" do
        assert_equal "/account/new", new_account_path
      end
      should "generate edit_account_path" do
        assert_equal "/account/edit", edit_account_path
      end
      should "generate signup_path" do
        assert_equal "/signup", signup_path
      end
    end
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
    should_render_template "users/new"
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
        post :create, :user => { :password => "bobby", :password_confirmation => "bobby" }
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.accounts.create.notice")
      should_redirect_to("the root url") { root_url }
    end

    context "with failed creation" do
      setup do
        stub(@the_user).signup!{ false }
        post :create, :user => { :password => "bobby", :password_confirmation => "bobby" }
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "users/new"
    end
  end

  context "with a regular user" do
    setup do
      @the_user = User.generate!
      @the_user.activate!
      UserSession.create(@the_user)
    end

    context "on GET to :show" do
      setup do
        get :show
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "users/show"
    end

    context "on GET to :edit" do
      setup do
        get :edit
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "users/edit"
    end
  end
end
