require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a result exists" do
  Ontology.all.destroy!
  request(resource(:ontologies), :method => "POST", :params => Factory.attributes_for(:ontology))
end

describe "resource(:ontologies)" do

  describe "GET", :given => "a result exists" do

    before(:each) do
      @response = request(resource(:ontologies))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of ontologies" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end

    it "has a list of ontologies" do
      @response.should have_selector('div.page-title', :content => "Ontologies")
    end
  end
  
end
