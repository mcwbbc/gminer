require 'test_helper'

class ActivationsControllerTest < ActionController::TestCase

  should_have_before_filter :require_no_user, :only => [:new, :create]

  context "routing" do
    should_route :get, "/activate/ABC", :controller => "activations", :action => "new", :activation_code => "ABC"
    should_route :post, "/finish_activate/1", :action=>"create", :controller=>"activations", :id => 1

    context "named routes" do
      setup do
        stub(controller).require_no_user{ true }
        @the_user = User.generate!
        stub(User).find_using_perishable_token{ @the_user }
        get :new, :activation_code => "ABC"
      end

      should "generate activate_path" do
        assert_equal "/activate/ABC", activate_path("ABC")
      end
      should "generate finish_activate_path" do
        assert_equal "/finish_activate/1", finish_activate_path(1)
      end
    end
  end

  context "on GET to :new" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user = User.generate!
    end

    context "with correct activation code" do
      setup do
        stub(User).find_using_perishable_token{ @the_user }
        get :new, :activation_code => "ABC"
      end

    should_assign_to(:user) { @the_user }
    should_respond_with :success
    should_render_template "activations/new"
    should_not_set_the_flash
    end

    context "with incorrect activation code" do
      should "raise an exception" do
        assert_raise Exception do
          stub(User).find_using_perishable_token{ nil }
          get :new, :activation_code => "XYZ"
        end
      end
    end

  end

  context "on POST to :create" do
    setup do
      stub(controller).require_no_user{ true }
      @the_user = User.generate!
      stub(User).find{ @the_user }
    end

    context "with active user" do
      setup do
        @the_user.activate!
        post :create, :user => { :id => @the_user.id, :password => "sekrit", :password_confirmation => "sekrit"}
      end

      should_respond_with :redirect
      should_redirect_to("the root url") { root_url }

    end

    context "with successful activation" do
      setup do
        stub(@the_user).activate!{ true }
        post :create, :user => { :id => @the_user.id, :password => "sekrit", :password_confirmation => "sekrit"}
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :redirect
      should_set_the_flash_to I18n.t("flash.activations.create.notice")
      should_redirect_to("the root url") { root_url }
    end

    context "with failed activation" do
      setup do
        stub(@the_user).activate!{ false }
        post :create, :user => { :id => @the_user.id, :password => "sekrit", :password_confirmation => "sekrit"}
      end

      should_assign_to(:user) { @the_user }
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end
  end

end
