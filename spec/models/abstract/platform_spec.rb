require 'spec_helper'

class FakeClass
  include Abstract::Platform
end

describe Abstract::Platform do

  describe "persist" do
    it "should set the fields and save to the database" do
      p = Factory.build(:platform)
      p.stub!(:platform_hash).and_return({"organism" => "rat", "title" => "title"})
      p.should_receive(:title=).with("title").and_return(true)
      p.should_receive(:organism=).with("rat").and_return(true)
      p.should_receive(:download_file).and_return(true)
      p.should_receive(:save!).and_return(true)
      p.persist
    end
  end

  describe "platform hash" do
    it "should return the hash for the platform by parsing the file" do
      p = Factory.build(:platform)
      p.should_receive(:field_array).and_return(["fields"])
      p.should_receive(:platform_filename).and_return("file.soft")
      p.should_receive(:file_hash).with(["fields"], "file.soft").and_return(true)
      p.platform_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      p = Factory.build(:platform)
      p.field_array.should == [{:annotatable=>true, :value=>"Platform Title", :regex=>/^!Platform_title = (.+?)$/, :name=>"title"}, {:annotatable=>true, :value=>"rat", :regex=>/^!Platform_organism = (.+?)$/, :name=>"organism"}, {:annotatable=>false, :value=>"", :regex=>/^!Platform_series_id = (GSE\d+)/, :name=>"series_ids"}]
    end
  end

  describe "download file" do
    it "should download the file from geo" do
      f = FakeClass.new
      f.stub(:geo_accession).and_return("GPL1355")
      f.should_receive(:make_directory).with(/datafiles\/GPL1355$/).and_return(true)
      f.should_receive(:write_file).with(/datafiles\/GPL1355\/GPL1355.soft$/, "data").and_return(true)
      GeoService.should_receive(:get).with("/geo/query/acc.cgi", {:format=>:plain, :query=>{"acc"=>"GPL1355", "targ"=>"self", "form"=>"text", "view"=>"brief"}}).and_return("data")
      f.download_file
    end
  end

  describe "platform path" do
    it "should return the path for the platforms" do
      p = Factory.build(:platform)
      p.platform_path.should match(/datafiles\/GPL1355$/)
    end
  end

  describe "platform filename" do
    it "should return the path for the platforms" do
      p = Factory.build(:platform)
      p.platform_filename.should match(/datafiles\/GPL1355\/GPL1355.soft$/)
    end
  end

  describe "to_param" do
    it "should return the geo_accession as the param" do
      p = Factory.build(:platform)
      p.to_param.should == "GPL1355"
    end
  end
end
