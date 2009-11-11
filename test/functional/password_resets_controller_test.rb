require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

  should_have_before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  context "routing" do
    should_route :post, "/password_resets", :action=>"create", :controller=>"password_resets"
    should_route :get, "/password_resets/new", :action=>"new", :controller=>"password_resets"
    should_route :get, "/password_resets/1/edit", :action=>"edit", :controller=>"password_resets", :id => 1
    should_route :put, "/password_resets/1", :action=>"update", :controller=>"password_resets", :id => 1

    context "named routes" do
      setup do
        get :new
      end

      should "generate new_password_reset_path" do
        assert_equal "/password_resets/new", new_password_reset_path
      end
      should "generate edit_password_reset_path" do
        assert_equal "/password_resets/1/edit", edit_password_reset_path(1)
      end
      should "generate password_reset_path" do
        assert_equal "/password_resets/1", password_reset_path(1)
      end
    end
  end

  context "on GET to :new" do
    setup do
      stub(controller).require_no_user{ true }
      get :new
    end

    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create" do
    setup do
      stub(Notifier).deliver_password_reset_intructions{ nil }
      stub(controller).require_no_user{ true }
    end

    context "with user not found" do
      setup do
        stub(User).find_by_email{ nil }
        post :create, :email => "foo@example.com"
      end

      should_respond_with :success
      should_set_the_flash_to I18n.t("flash.password_resets.create.error")
      should_render_template :new
    end

    context "with user found" do
      setup do
        @user = User.generate!(:email => "foo@example.com")
        post :create, :email => "foo@example.com"
      end

      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.password_resets.create.notice")
      should_redirect_to("the home page") { root_url }
    end
  end

  context "on GET to :edit" do
    setup do
      stub(controller).require_no_user{ true }
      @user = User.generate!
      stub(User).find_using_perishable_token{ @user }
      get :edit, :id => "the token"
    end

    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
  end

  context "on PUT to :update" do
    setup do
      stub(controller).require_no_user{ true }
      @user = User.generate!
      stub(User).find_using_perishable_token{ @user }
    end

    context "with successful save" do
      setup do
        stub.instance_of(User).save{ true }
        put :update, :id => "the token", :user => {:password => "the new password", :password_confirmation => "the new password"}
      end

      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.password_resets.update.notice")
      should_redirect_to("the user's page") { account_url }
    end

    context "with failed save" do
      setup do
        stub.instance_of(User).save{ false }
        put :update, :id => "the token", :user => {:password => "the new password", :password_confirmation => "the new password"}
      end

      should_respond_with :success
      should_not_set_the_flash
      should_render_template :edit
    end
  end
end
