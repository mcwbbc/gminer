require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a series item exists" do
  SeriesItem.all.destroy!
  request(resource(:series_items), :method => "POST", :params => Factory.attributes_for(:series_item) )
end

describe "resource(:series_items)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:series_items))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a form" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end
    
  end
  
  describe "GET", :given => "a series item exists" do
    before(:each) do
      @response = request(resource(:series_items))
    end
    
    it "has a title" do
      @response.should have_selector('div.page-title', :content => "Series")
    end
  end
end
