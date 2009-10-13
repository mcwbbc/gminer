require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlatformsController do

  describe "handling GET /platforms" do
    before(:each) do
      platform = Platform.spawn
      @platforms = [platform]
      @platforms.stub!(:total_pages).and_return(1)
      Platform.stub!(:page).and_return(@platforms)
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
      platform = Platform.spawn
      Platform.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_return(platform)
      platform.should_receive(:prev_next).and_return(["GDS1", "GDS3"])
      get :show, :id => "GDS1234"
      assigns[:platform].should equal(platform)
    end

    it "redirects for an invalid platform" do
      Platform.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "GDS1234"
      response.should redirect_to(platforms_url)
    end
  end
end
