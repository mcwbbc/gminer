require 'spec_helper'

describe Gminer::Platform do

  describe "for_probeset" do
    it "should return an array of platforms for the selected probeset name" do
      Gminer::Platform.should_receive(:find).with(:all, :select => "platforms.*", :joins => "INNER JOIN samples ON platforms.id = samples.platform_id INNER JOIN detections ON samples.id = detections.sample_id INNER JOIN probesets ON probesets.id = detections.probeset_id AND probesets.name = '1234_ab'", :group  => "platforms.geo_accession", :order  => "platforms.geo_accession").and_return([])
      Gminer::Platform.for_probeset("1234_ab")
    end
  end

  describe "create series" do
    it "should create the series, save it and create the samples if it exists" do
      p = Factory.build(:platform)
      s = mock(SeriesItem)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      p.create_series(["1"])
    end

    it "should create the series, save it and create the samples if it exists and we create detections" do
      p = Factory.build(:platform)
      s = mock(SeriesItem)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      Detection.should_receive(:disable_keys).and_return(true)
      Detection.should_receive(:enable_keys).and_return(true)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      p.create_series(["1"], true)
    end

    it "should create the series, save it and create the samples if it doesn't exist" do
      p = Factory.build(:platform)
      s = mock(SeriesItem)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      SeriesItem.should_receive(:new).with({:geo_accession=>"1", :platform_id => p.id}).and_return(s)
      p.create_series(["1"])
    end

    it "should create the series, save it and create the samples if it doesn't exist and we create detections" do
      p = Factory.build(:platform)
      s = mock(SeriesItem)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_samples).and_return(true)
      Detection.should_receive(:enable_keys).and_return(true)
      Detection.should_receive(:disable_keys).and_return(true)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      SeriesItem.should_receive(:new).with({:geo_accession=>"1", :platform_id => p.id}).and_return(s)
      p.create_series(["1"], true)
    end
  end

end
