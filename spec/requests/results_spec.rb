require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a result exists" do
  Result.all.destroy!
  request(resource(:results), :method => "POST", :params => Factory.attributes_for(:result))
end

describe "resource(:results)" do

  describe "GET", :given => "a result exists" do

    before(:each) do
      @response = request(resource(:results))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of results" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end

    it "has a list of results" do
      @response.should have_selector('div.page-title', :content => "Results")
    end
  end
  
end
