require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a sample exists" do
  Sample.all.destroy!
  request(resource(:samples), :method => "POST", :params => Factory.attributes_for(:sample))
end

describe "resource(:samples)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:samples))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of samples" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end
    
  end
  
  describe "GET", :given => "a sample exists" do
    before(:each) do
      @response = request(resource(:samples))
    end
    
    it "has a list of samples" do
      @response.should have_selector('div.page-title', :content => "Samples")
    end
  end
  
end
