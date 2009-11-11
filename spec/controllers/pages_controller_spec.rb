require 'spec_helper'

describe PagesController do

  describe "handling GET /pages/home" do
    before(:each) do
      #probably should put in some mock code
    end

    def do_get
      get :home
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('home')
    end

    it "should assign the found annotations for the view" do
      do_get
      assigns[:terms].should == [{:title=>"All Terms", :values=>[]}, {:title=>"Rat Strain Ontology", :values=>[]}, {:title=>"Mouse adult gross anatomy", :values=>[]}]
    end

  end

  describe "handling GET /pages/kaboom" do
    it "should be successful" do
      u = User.spawn
      User.should_receive(:first).and_return(u)
      u.should_receive(:kaboom!)
      get :kaboom
      response.should be_success
    end
  end

end
