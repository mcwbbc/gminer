require 'spec_helper'

describe DetectionsController do

  #Delete this example and add some real ones
  it "should use DetectionsController" do
    controller.should be_an_instance_of(DetectionsController)
  end

  describe "handling GET /detections" do
    before(:each) do
      detection = Detection.spawn
      @detections = [detection]
      @detections.stub!(:total_pages).and_return(1)
      Detection.stub!(:page).and_return(@detections)
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
      assigns[:detections].should == @detections
    end

  end

  describe "GET show" do
    it "assigns the requested detection as @detection" do
      detection = Detection.spawn
      Detection.stub!(:find).with("1234").and_return(detection)
      get :show, :id => "1234"
      assigns[:detection].should equal(detection)
    end

    it "redirects for an invalid detection" do
      Detection.stub!(:find).with("1234").and_raise(ActiveRecord::RecordNotFound)
      get :show, :id => "1234"
      response.should redirect_to(detections_url)
    end
  end
end
