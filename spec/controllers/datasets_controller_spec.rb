require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DatasetsController do

  describe "handling GET /datasets" do
    before(:each) do
      dataset = Dataset.spawn
      @datasets = [dataset]
      @datasets.stub!(:total_pages).and_return(1)
      Dataset.stub!(:page).and_return(@datasets)
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
      assigns[:datasets].should == @datasets
    end

  end

  describe "GET show" do
    it "assigns the requested dataset as @dataset" do
      user = User.spawn(:id => "1")
      controller.should_receive(:admin_logged_in?).and_return(true)
      controller.should_receive(:current_user).and_return(user)
      dataset = Dataset.spawn
      Dataset.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_return(dataset)
      Annotation.should_receive(:for_item).with(dataset, user.id)
      dataset.should_receive(:prev_next).and_return(["GDS1", "GDS3"])
      dataset.should_receive(:count_by_ontology_array).and_return({})
      get :show, :id => "GDS1234"
      assigns[:dataset].should equal(dataset)
    end

    it "redirects for an invalid dataset" do
      Dataset.stub!(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "GDS1234"
      response.should redirect_to(datasets_url)
    end
  end
end
