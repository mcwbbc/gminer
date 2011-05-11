require 'spec_helper'

describe OntologyTermsController do

  describe "handling GET /ontology_terms" do
    before(:each) do
      ontology_term = Factory.build(:ontology_term)
      @ontology_terms = [ontology_term]
      @ontology_terms.stub!(:total_pages).and_return(1)
      OntologyTerm.stub!(:page).and_return(@ontology_terms)
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
      assigns[:ontology_terms].should == @ontology_terms
    end

  end

  describe "GET show" do
    it "assigns the requested ontology_term as @ontology_term" do
      page_array = []
      page_array.stub!(:total_entries).and_return(1)
      page_array.stub!(:total_pages).and_return(1)
      ontology_term = Factory.build(:ontology_term)
      OntologyTerm.stub!(:first).with(:conditions => {:term_id => "term_id"}).and_return(ontology_term)
      AnnotationClosure.should_receive(:page).and_return(page_array)
      Annotation.should_receive(:page).and_return(page_array)
      ontology_term.should_receive(:parent_closures).and_return([])
      ontology_term.should_receive(:child_closures).and_return([])
      ontology_term.should_receive(:geo_counts).and_return([])

      get :show, :id => "term_id", :format => "html"
      assigns[:ontology_term].should equal(ontology_term)
    end

    it "redirects for an invalid ontology_term" do
      OntologyTerm.stub!(:first).with(:conditions => {:term_id => "term_id"}).and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "term_id"
      response.should redirect_to(ontology_terms_url)
    end
  end
end
