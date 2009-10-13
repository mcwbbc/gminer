require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OntologiesController do

  describe "handling GET /ontologies" do
    before(:each) do
      ontology = Ontology.spawn
      @ontologies = [ontology]
      @ontologies.stub!(:total_pages).and_return(1)
      Ontology.stub!(:page).and_return(@ontologies)
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
      assigns[:ontologies].should == @ontologies
    end

  end

  describe "GET show" do
    it "assigns the requested ontology as @ontology" do
      ontology = Ontology.spawn
      Ontology.stub!(:find).with("1").and_return(ontology)
      get :show, :id => "1"
      assigns[:ontology].should equal(ontology)
    end

    it "redirects for an invalid ontology" do
      Ontology.stub!(:find).with("1").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "1"
      response.should redirect_to(ontologies_url)
    end
  end
end
