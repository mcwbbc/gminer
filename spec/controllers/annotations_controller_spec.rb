require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnnotationsController do

  def mock_annotation(stubs={})
    @mock_annotation ||= mock_model(Annotation)
  end

  describe "handling GET /annotations/audit" do
    before(:each) do
      @annotations = [mock_annotation]
      @annotations.stub!(:total_pages).and_return(1)
      Annotation.stub!(:page).and_return(@annotations)
      controller.stub!(:admin_required).and_return(true)
    end
  
    def do_get
      get :audit
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('audit')
    end
  
    it "should assign the found annotations for the view" do
      do_get
      assigns[:annotations].should == @annotations
    end

  end

  describe "handling GET /annotations" do
    before(:each) do
      @annotations = [mock_annotation]
      @annotations.stub!(:total_pages).and_return(1)
      Annotation.stub!(:page).and_return(@annotations)
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
      assigns[:annotations].should == @annotations
    end

  end

  describe "GET show" do
    it "assigns the requested annotation as @annotation" do
      Annotation.stub!(:find).with("37").and_return(mock_annotation)
      get :show, :id => "37"
      assigns[:annotation].should equal(mock_annotation)
    end

    it "redirects for an invalid annotation" do
      Annotation.stub!(:find).with("37").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "37"
      response.should redirect_to(annotations_url)
    end
  end

  describe "POST curate" do
    it "assigns the requested annotation as @annotation" do
      controller.stub!(:admin_required).and_return(true)
      annotation = Annotation.spawn
      annotation.should_receive(:toggle).and_return(true)
      annotation.should_receive(:verified?).and_return(true)
      Annotation.stub!(:find).with("37").and_return(annotation)
      post :curate, :id => "37"
      response.body.should == {:result => true}.to_json
    end
  end

  describe "POST valid" do
    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_receive(:update_all).with("verified = 1, audited = 1", "id IN (1,2)").and_return(true)
      post :valid, :selected_annotations => ["1","2"]
      response.body.should == "[\"1\",\"2\"]"
    end

    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_not_receive(:update_all).with("verified = 1, audited = 1", "id IN (1,2)").and_return(true)
      post :valid
      response.body.should == "null"
    end
  end

  describe "POST invalid" do
    it "sets the supplied annotation ids to invalid and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_receive(:update_all).with("verified = 0, audited = 1", "id IN (1,2)").and_return(true)
      post :invalid, :selected_annotations => ["1","2"]
      response.body.should == "[\"1\",\"2\"]"
    end

    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_not_receive(:update_all).with("verified = 0, audited = 1", "id IN (1,2)").and_return(true)
      post :invalid
      response.body.should == "null"
    end
  end

  describe "GET cloud" do
    before(:each) do
      @annotation_hash = {}
      @anatomy_terms = {}
      @rat_strain_terms = {}
      Annotation.should_receive(:build_cloud).with("1111|abcd").and_return([@annotation_hash, @anatomy_terms, @rat_strain_terms])
    end

    it "should render the html" do
      Annotation.should_receive(:count_by_ontology_array).and_return(1)
      get :cloud, :term_array => "1111|abcd", :format => "html"
    end

    it "should render the js" do
      post :cloud, :term_array => "1111|abcd", :format => "js"
    end
  end

end
