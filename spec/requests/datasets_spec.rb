require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a dataset exists" do
  Dataset.all.destroy!
  request(resource(:datasets), :method => "POST", :params => Factory.attributes_for(:dataset))
end

describe "resource(:datasets)" do

  describe "GET", :given => "a dataset exists" do

    before(:each) do
      @response = request(resource(:datasets))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of datasets" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end

    it "has a list of datasets" do
      @response.should have_selector('div.page-title', :content => "Datasets")
    end
  end
  
end
