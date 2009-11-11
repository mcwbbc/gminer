require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SamplesController do

  describe "handling GET /samples" do
    before(:each) do
      sample = Sample.spawn
      @samples = [sample]
      @samples.stub!(:total_pages).and_return(1)
      Sample.stub!(:page).and_return(@samples)
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
      assigns[:samples].should == @samples
    end

  end

  describe "GET show" do
    it "assigns the requested sample as @sample" do
      user = User.spawn(:id => "1")
      controller.should_receive(:admin_logged_in?).and_return(true)
      controller.should_receive(:current_user).and_return(user)

      series_item = SeriesItem.spawn
      sample = Sample.spawn(:series_item => series_item)
      Sample.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_return(sample)
      sample.should_receive(:prev_next).and_return(["GDS1", "GDS3"])
      sample.should_receive(:count_by_ontology_array).and_return({})
      get :show, :id => "GDS1234"
      assigns[:sample].should equal(sample)
    end

    it "redirects for an invalid sample" do
      Sample.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "GDS1234"
      response.should redirect_to(samples_url)
    end
  end
end
