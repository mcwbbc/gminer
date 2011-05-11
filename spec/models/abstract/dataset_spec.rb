require 'spec_helper'

describe Abstract::Dataset do

  describe "download file" do
    it "should download the file via ftp" do
      ds = Factory.build(:dataset)
      ds.should_receive(:dataset_path).and_return("path")
      ds.should_receive(:make_directory).with("path").and_return(true)
      ds.should_receive(:dataset_filename).and_return("filename")
      ds.should_receive(:local_dataset_filename).twice.and_return("local_filename")
      ds.should_receive(:gunzip).with("local_filename.gz").and_return(true)
      ftp = mock("ftp")
      ftp.should_receive(:login).and_return(true)
      ftp.should_receive(:passive=).with(true).and_return(true)
      ftp.should_receive(:chdir).with("/pub/geo/DATA/SOFT/GDS").and_return(true)
      ftp.should_receive(:getbinaryfile).with("filename.gz", "local_filename.gz", 1024).and_return(true)
      Net::FTP.should_receive(:open).with('ftp.ncbi.nih.gov').and_yield(ftp)
      ds.download_file
    end
  end

  describe "dataset hash" do
    it "should return the hash for the dataset by parsing the file" do
      ds = Factory.build(:dataset)
      ds.should_receive(:field_array).and_return(["fields"])
      ds.should_receive(:local_dataset_filename).and_return("file.soft")
      ds.should_receive(:file_hash).with(["fields"], "file.soft").and_return(true)
      ds.dataset_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      ds = Factory.build(:dataset)
      ds.field_array.should == [{:regex=>/^!dataset_platform_organism = (.+?)$/, :value=>"rat", :name=>"organism", :annotatable=>true}, {:regex=>/^!dataset_title = (.+?)$/, :value=>"rat strain dataset", :name=>"title", :annotatable=>true}, {:regex=>/^!dataset_description = (.+?)$/, :value=>"rat strain description", :name=>"description", :annotatable=>true}, {:regex=>/^!dataset_pubmed_id = (\d+)$/, :value=>"1234", :name=>"pubmed_id", :annotatable=>false}, {:regex=>/^!dataset_reference_series = (GSE\d+)$/, :value=>"", :name=>"reference_series", :annotatable=>false}, {:regex=>/^!dataset_platform = (GPL\d+)$/, :value=>"", :name=>"platform_geo_accession", :annotatable=>false}]
    end
  end

  describe "download" do
    it "should download the file if it doesn't exist" do
      ds = Factory.build(:dataset)
      File.should_receive(:exists?).with(/datafiles\/GDS8700\/GDS8700\.soft$/).and_return(false)
      ds.should_receive(:download_file).and_return(true)
      ds.download
    end
  end

  describe "dataset path" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.dataset_path.should match(/datafiles\/GDS8700$/)
    end
  end

  describe "dataset filename" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.dataset_filename.should == "GDS8700.soft"
    end
  end

  describe "local dataset filename" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.local_dataset_filename.should match(/datafiles\/GDS8700\/GDS8700.soft$/)
    end
  end

  describe "to_param" do
    it "should return the geo_accession as the param" do
      ds = Factory.build(:dataset)
      ds.to_param.should == "GDS8700"
    end
  end

end
