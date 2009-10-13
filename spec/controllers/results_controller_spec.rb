require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResultsController do

  describe "handling GET /results" do
    before(:each) do
      result = Result.spawn
      @results = [result]
      @results.stub!(:total_pages).and_return(1)
      Result.stub!(:page).and_return(@results)
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
      assigns[:results].should == @results
    end

  end

  describe "GET show" do
    it "assigns the requested result as @result" do
      result = Result.spawn
      Result.stub!(:find).with("1").and_return(result)
      get :show, :id => "1"
      assigns[:result].should equal(result)
    end

    it "redirects for an invalid result" do
      Result.stub!(:find).with("1").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "1"
      response.should redirect_to(results_url)
    end
  end
end
