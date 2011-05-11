require 'spec_helper'

describe ProbesetsController do

  #Delete this example and add some real ones
  it "should use ProbesetsController" do
    controller.should be_an_instance_of(ProbesetsController)
  end

  describe "handling GET /probesets" do
    before(:each) do
      probeset = Factory.build(:probeset)
      @probesets = [probeset]
      @probesets.stub!(:total_pages).and_return(1)
      Probeset.stub!(:page).and_return(@probesets)
      Probeset.should_receive(:generate_platform_hash).and_return({})
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
      assigns[:probesets].should == @probesets
    end

  end

  describe "GET show" do
    describe "with valid request" do
      before(:each) do
        @probeset = Factory.build(:probeset)
        Probeset.stub!(:first).with(:conditions => {:name => "1234_at"}).and_return(@probeset)
      end

      it "assigns the requested probeset as @probeset" do
        @probeset.should_receive(:generate_term_array).and_return(["valid"])
        @probeset.should_receive(:generate_high_chart).with(["valid"]).and_return("image")
        get :show, :id => "1234_at"
        assigns[:probeset].should equal(@probeset)
      end

      it "not generate the image if we have an empty term array" do
        @probeset.should_receive(:generate_term_array).and_return([])
        get :show, :id => "1234_at"
        assigns[:probeset].should equal(@probeset)
      end
    end

    it "redirects for an invalid probeset" do
      Probeset.stub!(:first).with(:conditions => {:name => "1234_at"}).and_return(nil)
      get :show, :id => "1234_at"
      response.should redirect_to(probesets_url)
    end
  end


  describe "GET compare" do
    describe "with valid request" do
      it "assigns the requested probeset as @probeset" do
        @probeset = Factory.build(:probeset)
        Probeset.stub!(:first).with(:conditions => {:name => "1234_at"}).and_return(@probeset)
        get :compare, :id => "1234_at"
        assigns[:probeset].should equal(@probeset)
      end
    end

    it "redirects for an invalid probeset" do
      Probeset.stub!(:first).with(:conditions => {:name => "1234_at"}).and_return(nil)
      get :compare, :id => "1234_at"
      response.should redirect_to(probesets_url)
    end
  end
end

