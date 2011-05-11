require 'spec_helper'

describe AnnotationsController do

  login_user

  def mock_annotation(stubs={})
    @mock_annotation ||= mock_model(Annotation)
  end

  describe "handling GET /annotations/audit" do
    before(:each) do
      @annotations = [mock_annotation]
      @annotations.stub!(:total_pages).and_return(1)
      Annotation.stub!(:find_for_curation).and_return(@annotations)
      controller.stub!(:set_ontology_dropdown).and_return("1000")
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

    ["All", "Valid", "Invalid", "Unaudited"].each do |status|
      it "should do filter results based on #{status}" do
        get :audit, :status => status
        response.should be_success
      end
    end
  end

  describe "handling GET /annotations" do
    before(:each) do
      @annotations = [@mock_annotation]
      @annotations.stub!(:total_pages).and_return(1)
      Annotation.stub!(:page).and_return(@annotations)
      controller.stub!(:set_ontology_dropdown).and_return("1000")
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

  describe "POST /annotations" do
    before(:each) do
      controller.stub!(:admin_required).and_return(true)
      @params = {"from"=>"335", "geo_accession"=>"GSE10412", "status"=>"audited", "to"=>"349", "curated_by_id"=>"1", "created_by_id"=>"1", "field_name"=>"summary", "ncbo_id"=>"1150", "description"=>"Triazole Antifungal Toxicogenomics: rat_repro_Testis", "verified"=>"true", "ncbo_term_id"=>"RS:0001833"}
      @annotation = Factory.create(:annotation, @params)
      Annotation.should_receive(:new).with(@params).and_return(@annotation)
    end

    describe "failure to save the annotation" do
      it "should fail with invalid term" do
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "1150|RS:0001833"}).and_return(nil)
        post :create, {:format => "js", :annotation => @params}
        assigns[:result].should == {'status' => "failure", 'message' => "ERROR: #<ActiveRecord::RecordNotFound: Invalid ontology term>"}
      end

      it "should fail with invalid ontology" do
        term = Factory.create(:ontology_term)
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "1150|RS:0001833"}).and_return(term)
        Ontology.should_receive(:first).with(:conditions => {:ncbo_id => "1150"}).and_return(nil)
        post :create, {:format => "js", :annotation => @params}
        assigns[:result].should == {'status' => "failure", 'message' => "ERROR: #<ActiveRecord::RecordNotFound: Invalid ontology>"}
      end
    end

    it "should save the annotation" do
      term = Factory.create(:ontology_term)
      ontology = Factory.create(:ontology)
      OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "1150|RS:0001833"}).and_return(term)
      Ontology.should_receive(:first).with(:conditions => {:ncbo_id => "1150"}).and_return(ontology)
      term.stub!(:id).and_return(8)
      ontology.stub!(:id).and_return(9)
      @annotation.should_receive(:ontology_id=).with(9).and_return(true)
      @annotation.should_receive(:ontology_term_id=).with(8).and_return(true)
      @annotation.should_receive(:identifier=).with("GSE10412-summary-1150|RS:0001833").and_return(true)

      @annotation.should_receive(:save).and_return(true)
      post :create, {:format => "js", :annotation => @params}
      assigns[:result].should == {'status' => "success", 'message' => "Annotation successfully saved!"}
    end
  end


  describe "POST curate" do
    it "assigns the requested annotation as @annotation" do
      controller.stub!(:admin_required).and_return(true)
      annotation = Factory.build(:annotation)
      annotation.should_receive(:set_status).with(1).and_return(true)
      annotation.should_receive(:verified?).and_return(true)
      Annotation.stub!(:find).with("37").and_return(annotation)
      post :curate, :id => "37"
      response.body.should == {:result => true, :css_class => 'predicate-text'}.to_json
    end
  end

  describe "POST mass_curate" do
    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_receive(:update_all).with("verified = 1, status = 'audited', curated_by_id = 1, updated_at = '#{Time.now}'", "id IN (1,2)").and_return(true)
      post :mass_curate, :selected_annotations => ["1","2"], :verified => "1"
      response.body.should == "[\"1\",\"2\"]"
    end

    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_not_receive(:update_all).with("verified = 1, status = 'audited'", "id IN (1,2)").and_return(true)
      post :mass_curate, :verified => "1"
      response.body.should == "null"
    end

    it "sets the supplied annotation ids to invalid and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_receive(:update_all).with("verified = 0, status = 'audited', curated_by_id = 1, updated_at = '#{Time.now}'", "id IN (1,2)").and_return(true)
      post :mass_curate, :selected_annotations => ["1","2"], :verified => "0"
      response.body.should == "[\"1\",\"2\"]"
    end

    it "sets the supplied annotation ids to verified and audited" do
      controller.stub!(:admin_required).and_return(true)
      Annotation.should_not_receive(:update_all).with("verified = 0, status = 'audited'", "id IN (1,2)").and_return(true)
      post :mass_curate, :verified => "0"
      response.body.should == "null"
    end
  end

  describe "GET cloud" do
    before(:each) do
      @annotations = []
      @anatomy_terms = []
      @rat_strain_terms = []
      Annotation.should_receive(:build_cloud).with(["1111|abcd", "1234|defg"], 3).and_return([123, @annotations, @anatomy_terms, @rat_strain_terms])
    end

    it "should render the html" do
      get :cloud, :term_array => ["1111|abcd", "1234|defg"], :page => 3, :format => "html"
      assigns[:term_array].should == ["1111|abcd", "1234|defg"]
    end

    it "should render the js" do
      post :cloud, :term_array => ["1111|abcd", "1234|defg"], :page => 3, :format => "js"
      assigns[:term_array].should == ["1111|abcd", "1234|defg"]
    end
  end

end
