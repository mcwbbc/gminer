require 'spec_helper'

describe Mongo::Platform do

  describe "create series" do
    it "should create the series, save it and create the samples if it exists" do
      p = Factory.build(:mongo_platform)
      s = Factory.build(:mongo_series_item)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      Mongo::SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      p.create_series(["1"])
    end

    it "should create the series, save it and create the samples if it doesn't exist" do
      p = Factory.build(:mongo_platform)
      s = Factory.build(:mongo_series_item)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      Mongo::SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      Mongo::SeriesItem.should_receive(:new).with({:geo_accession=>"1", :platform_id => p.id}).and_return(s)
      p.create_series(["1"])
    end
  end

end
