require 'spec_helper'

describe SeriesItem do

  describe "page" do
    it "should call paginate" do
      SeriesItem.should_receive(:paginate).with({:conditions=>"conditions", :order => :geo_accession, :page=>2, :per_page=>20}).and_return(true)
      SeriesItem.page("conditions", 2, 20)
    end
  end

  describe "create samples" do
    it "should check if the sample exists, and do nothing if it does" do
      se = Factory.build(:series_item)
      s = mock(Sample)
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      se.create_samples(["1"])
    end

    it "should check if the sample exists, and do nothing if it does and check probesets" do
      Probeset.should_receive(:all).and_return([])
      se = Factory.build(:series_item)
      s = mock(Sample)
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(s)
      se.create_samples(["1"], true)
    end

    it "should check if the sample exists, save it and create the detections if it doesn't exist" do
      p = Factory.build(:platform)
      se = Factory.build(:series_item, :platform => p)
      s = mock(Sample)
      s.should_receive(:persist).and_return(true)
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      Sample.should_receive(:new).with({:geo_accession=>"1", :series_item_id => se.id, :platform_id => p.id}).and_return(s)
      se.create_samples(["1"])
    end

    it "should check if the sample exists, save it and create the detections if it doesn't exist and check probesets" do
      p = Factory.build(:platform)
      se = Factory.build(:series_item, :platform => p)
      s = mock(Sample)
      s.should_receive(:persist).and_return(true)
      s.should_receive(:create_detections).with({}).and_return(true)
      Probeset.should_receive(:all).and_return([])
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "1"}).and_return(nil)
      Sample.should_receive(:new).with({:geo_accession=>"1", :series_item_id => se.id, :platform_id => p.id}).and_return(s)
      se.create_samples(["1"], true)
    end
  end

end
