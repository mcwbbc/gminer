require 'spec_helper'

describe Abstract::SeriesItem do

  describe "download file" do
    it "should download the file via ftp" do
      s = Factory.build(:series_item)
      s.should_receive(:series_path).and_return("path")
      s.should_receive(:make_directory).with("path").and_return(true)
      s.should_receive(:family_filename).and_return("filename")
      s.should_receive(:local_family_filename).twice.and_return("local_filename")
      s.should_receive(:gunzip).with("local_filename.gz").and_return(true)
      ftp = mock("ftp")
      ftp.should_receive(:login).and_return(true)
      ftp.should_receive(:passive=).with(true).and_return(true)
      ftp.should_receive(:chdir).with("/pub/geo/DATA/SOFT/by_series/GSE8700").and_return(true)
      ftp.should_receive(:getbinaryfile).with("filename.gz", "local_filename.gz", 1024).and_return(true)
      Net::FTP.should_receive(:open).with('ftp.ncbi.nih.gov').and_yield(ftp)
      s.download_file
    end
  end

  describe "persist" do
    it "should set the fields and save to the database" do
      s = Factory.build(:series_item)
      s.stub!(:series_hash).and_return({"overall_design" => "ratdesign", "pubmed_id" => "1234", "summary" => "ratsummary", "title" => "title"})
      s.should_receive(:overall_design=).with("ratdesign").and_return(true)
      s.should_receive(:title=).with("title").and_return(true)
      s.should_receive(:summary=).with("ratsummary").and_return(true)
      s.should_receive(:pubmed_id=).with("1234").and_return(true)
      s.should_receive(:download).and_return(true)
      s.should_receive(:save!).and_return(true)
      s.persist
    end
  end

  describe "series hash" do
    it "should return the hash for the series by parsing the file" do
      s = Factory.build(:series_item)
      s.should_receive(:field_array).and_return(["fields"])
      s.should_receive(:local_series_filename).and_return("file.soft")
      s.should_receive(:file_hash).with(["fields"], "file.soft").and_return(true)
      s.series_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      s = Factory.build(:series_item)
      s.field_array.should == [{:annotatable=>true, :regex=>/^!Series_title = (.+)$/, :value=>"Series Title", :name=>"title"}, {:annotatable=>true, :regex=>/^!Series_summary = (.+)$/, :value=>"summary of series item", :name=>"summary"}, {:annotatable=>true, :regex=>/^!Series_overall_design = (.+?)$/, :value=>"rat strain series", :name=>"overall_design"}, {:annotatable=>false, :regex=>/^!Series_pubmed_id = (\d+)$/, :value=>"12345", :name=>"pubmed_id"}, {:annotatable=>false, :regex=>/^!Series_sample_id = (GSM\d+)$/, :value=>"", :name=>"sample_ids"}]
    end
  end

  describe "download" do
    it "should download the file if it doesn't exist" do
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      File.should_receive(:exists?).with(/datafiles\/GPL1355\/GSE8700\/GSE8700_family.soft$/).and_return(false)
      s.should_receive(:download_file).and_return(true)
      s.should_receive(:split_series_file).and_return(true)
      s.download
    end

    it "should do nothing if the file exists" do
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      File.should_receive(:exists?).with(/datafiles\/GPL1355\/GSE8700\/GSE8700_family.soft$/).and_return(true)
      s.should_not_receive(:download_file)
      s.should_not_receive(:split_series_file)
      s.download
    end
  end

  describe "series path" do
    it "should return the path for the series" do
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      s.series_path.should match(/datafiles\/GPL1355\/GSE8700$/)
    end
  end

  describe "family filename" do
    it "should return the path for the family filename" do
      s = Factory.build(:series_item)
      s.family_filename.should == "GSE8700_family.soft"
    end
  end

  describe "local family filename" do
    it "should return the path for the family filename" do
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      s.local_family_filename.should match(/datafiles\/GPL1355\/GSE8700\/GSE8700_family.soft/)
    end
  end

  describe "local series filename" do
    it "should return the path for the series" do
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      s.local_series_filename.should match(/datafiles\/GPL1355\/GSE8700\/GSE8700_series.soft/)
    end
  end

  describe "split series file" do
    it "should create sample files from the larger series file" do
      array = [
"^SERIES = GSE8700",
"!SeriesItem_title = Expression data from epididymal fat tissues of diet induced obese rats",
"!SeriesItem_geo_accession = GSE8700",
"^PLATFORM = GPL1355",
"!platform_table_end",
"^SAMPLE = GSM215572",
"!Sample_title = Diet Induced Obese rat C1",
"^SAMPLE = GSM215573",
"!Sample_title = rat 2"
              ]
      p = Factory.build(:platform)
      s = Factory.build(:series_item, :platform => p)
      File.should_receive(:open).with(/GSE8700_family.soft/, "rb", {:encoding=>"ISO-8859-1"}).and_return(array)
      s.should_receive(:write_file).with(/datafiles\/GPL1355\/GSE8700\/GSE8700_series.soft/, "^SERIES = GSE8700!SeriesItem_title = Expression data from epididymal fat tissues of diet induced obese rats!SeriesItem_geo_accession = GSE8700").and_return(true)
      s.should_receive(:write_file).with(/datafiles\/GPL1355\/GSE8700\/GSM215572_sample.soft/, "^SAMPLE = GSM215572!Sample_title = Diet Induced Obese rat C1").and_return(true)
      s.should_receive(:write_file).with(/datafiles\/GPL1355\/GSE8700\/GSM215573_sample.soft/, "^SAMPLE = GSM215573!Sample_title = rat 2").and_return(true)
      s.split_series_file
    end
  end

  describe "to_param" do
    it "should return the geo_accession as the param" do
      s = Factory.build(:series_item)
      s.to_param.should == "GSE8700"
    end
  end

end
