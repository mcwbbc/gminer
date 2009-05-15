require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Home do

  describe "handling GET /" do
    before(:each) do
      @response = request("/")
    end
  
    it "should be successful" do
      @response.should be_successful
    end

    it "should render the title" do
      @response.should have_selector("div.page-title")
    end

  end

end
