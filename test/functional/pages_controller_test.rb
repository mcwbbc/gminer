require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  context "routing" do
    should_route :get, "/", :action=>"home", :controller=>"pages"
    should_route :get, "/pages/foo", :controller=>"pages", :action => "foo"

    context "named routes" do
      setup do
        get :home
      end

      should "generate root_path" do
        assert_equal "/", root_path
      end
    end
  end

  {:home => 'gminer',
   :css_test => 'CSS Test', :upgrade => I18n.t('ie.browser_obsolete')}.each do | page, page_title |
    context "on GET to :#{page.to_s}" do
      setup do
        get page
      end

      should_respond_with :success
      should_not_set_the_flash
      should_render_template page
    end
  end

  context "on GET to :kaboom" do
    should "blow up predictably" do
      assert_raise NameError do
        @user = User.generate!
        get :kaboom
      end
    end
  end

end
