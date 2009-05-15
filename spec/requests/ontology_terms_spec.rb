require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a ontology_term exists" do
  OntologyTerm.all.destroy!
  request(resource(:ontology_terms), :method => "POST", :params => Factory.attributes_for(:ontology_term))
end

describe "resource(:ontology_terms)" do

  describe "GET", :given => "a ontology_term exists" do

    before(:each) do
      @response = request(resource(:ontology_terms))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of ontology_terms" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end

    it "has a list of ontology_terms" do
      @response.should have_selector('div.page-title', :content => "Ontology Terms")
    end
  end
  
end
