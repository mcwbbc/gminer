require 'spec_helper'

describe ReportsController do
  before(:each) do
    controller.stub!(:admin_required).and_return(true)
  end

  describe "handling GET /reports" do

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
    end

  end

  describe "GET /progress" do
    it "should be successful" do
      get :progress
      response.should be_success
    end

    it "should render progress template" do
      get :progress
      response.should render_template('progress')
    end
  end

  describe "GET /annotation" do
    it "should be successful" do
      get :annotation
      response.should be_success
    end

    it "should render annotation template" do
      get :annotation
      response.should render_template('annotation')
    end
  end

end
