require 'spec_helper'

describe JobsController do
  before(:each) do
    controller.stub!(:admin_required).and_return(true)
  end

  describe "handling GET /jobs" do
    before(:each) do
      job = Factory.build(:job)
      @jobs = [job]
      @jobs.stub!(:total_pages).and_return(1)
      Job.stub!(:page).and_return(@jobs)
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
      assigns[:jobs].should == @jobs
    end

  end

end

