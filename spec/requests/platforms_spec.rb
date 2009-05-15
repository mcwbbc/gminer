require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a platform exists" do
  Platform.all.destroy!
  request(resource(:platforms), :method => "POST", :params => Factory.attributes_for(:platform))
end

describe "resource(:platforms)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:platforms))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of platforms" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end
    
  end
  
  describe "GET", :given => "a platform exists" do
    before(:each) do
      @response = request(resource(:platforms))
    end
    
    it "has a list of platforms" do
      @response.should have_selector('div.page-title', :content => "Platforms")
    end
  end
  
end
