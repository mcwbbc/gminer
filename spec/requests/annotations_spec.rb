require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a annotation exists" do
  Annotation.all.destroy!
  request(resource(:annotations), :method => "POST", :params => Factory.attributes_for(:annotation))
end

describe "resource(:annotations)" do

  describe "GET", :given => "a annotation exists" do

    before(:each) do
      @response = request(resource(:annotations))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of annotations" do
      @response.should have_selector('form') do |form|
        form.inner_html.should have_selector('input')
      end 
    end

    it "has a list of annotations" do
      @response.should have_selector('div.page-title', :content => "Annotations")
    end
  end
  
end
