require 'spec_helper'

describe Mongo::SeriesItem do

  describe "create samples" do
    it "should check if the sample exists, and do nothing if it does" do
      se = Factory.build(:mongo_series_item)
      s = Factory.build(:mongo_sample)
      Mongo::Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      se.create_samples(["1"])
    end

    it "should check if the sample exists, save it if it doesn't exist" do
      p = Factory.build(:mongo_platform)
      se = Factory.build(:mongo_series_item, :platform => p)
      s = Factory.build(:mongo_sample)
      s.should_receive(:persist).and_return(true)
      Mongo::Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      Mongo::Sample.should_receive(:new).with({:geo_accession=>"1", :series_item_id => se.id, :platform_id => p.id}).and_return(s)
      se.create_samples(["1"])
    end
  end

end
