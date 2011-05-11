require 'spec_helper'

describe Mongo::Dataset do

  describe "persist" do
    it "should set the fields and save to the database" do
      ds = Factory.build(:mongo_dataset)
      ds.stub!(:dataset_hash).and_return({"organism" => "rat","title" => "rat","description" => "rat","reference_series" => "rat","platform_geo_accession" => "GPL1355", "pubmed_id" => "1234"})
      ds.should_receive(:download).and_return(true)
      ds.should_receive(:organism=).with("rat").and_return(true)
      ds.should_receive(:title=).with("rat").and_return(true)
      ds.should_receive(:description=).with("rat").and_return(true)
      ds.should_receive(:pubmed_id=).with("1234").and_return(true)
      ds.should_receive(:reference_series=).with("rat").and_return(true)
      platform = Factory.build(:mongo_platform)
      Mongo::Platform.should_receive(:first).with(:conditions => {:geo_accession => 'GPL1355'}).and_return(platform)
      ds.should_receive(:platform_id=).with(platform.id).and_return(true)
      ds.should_receive(:save!).and_return(true)
      ds.persist
    end
  end

end
