require 'spec_helper'

describe PlatformsController do

    include Devise::TestHelpers # to give your spec access to helpers

    def mock_user(stubs={})
        @mock_user ||= mock_model(User, stubs).as_null_object
    end

    before(:each) do
        # mock up an authentication in the underlying warden library
        request.env['warden'] = mock(Warden, :authenticate => mock_user,
                                             :authenticate! => mock_user)
    end

  describe "handling GET /platforms" do
    before(:each) do
      platform = Factory.build(:platform)
      @platforms = [platform]
      @platforms.stub!(:total_pages).and_return(1)
      Gminer::Platform.stub!(:page).and_return(@platforms)
    end

    def do_get
      get :index
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end

    it "should assign the found annotations for the view" do
      do_get
      assigns[:platforms].should == @platforms
    end

  end

  describe "GET show" do
    it "assigns the requested platform as @platform" do
      platform = Factory.build(:platform)
      Gminer::Platform.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_return(platform)
      platform.should_receive(:count_by_ontology_array).and_return({})
      platform.should_receive(:prev_next).and_return([1,3])
      get :show, :id => "GDS1234"
      assigns[:platform].should equal(platform)
    end

    it "redirects for an invalid platform" do
      Gminer::Platform.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "GDS1234"
      response.should redirect_to(platforms_url)
    end
  end
end
