require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Dataset do

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

  describe "persist" do
    it "should set the fields and save to the database" do
      ds = Factory.build(:dataset)
      ds.stub!(:dataset_hash).and_return({"organism" => "rat","title" => "rat","description" => "rat","reference_series" => "rat","platform_geo_accession" => "rat", "pubmed_id" => "1234"})
      ds.should_receive(:download).and_return(true)
      ds.should_receive(:organism=).with("rat").and_return(true)
      ds.should_receive(:title=).with("rat").and_return(true)
      ds.should_receive(:description=).with("rat").and_return(true)
      ds.should_receive(:pubmed_id=).with("1234").and_return(true)
      ds.should_receive(:reference_series=).with("rat").and_return(true)
      ds.should_receive(:platform_geo_accession=).with("rat").and_return(true)
      ds.should_receive(:save!).and_return(true)
      ds.persist
    end
  end

  describe "dataset hash" do
    it "should return the hash for the dataset by parsing the file" do
      ds = Factory.build(:dataset)
      ds.should_receive(:fields).and_return(["fields"])
      ds.should_receive(:local_dataset_filename).and_return("file.soft")
      ds.should_receive(:file_hash).with(["fields"], "file.soft").and_return(true)
      ds.dataset_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      ds = Factory.build(:dataset)
      ds.fields.should == [{:value=>"rat", :regex=>/^!dataset_platform_organism = (.+?)$/, :name=>"organism"}, {:value=>"rat strain dataset", :regex=>/^!dataset_title = (.+?)$/, :name=>"title"}, {:value=>"rat strain description", :regex=>/^!dataset_description = (.+?)$/, :name=>"description"}, {:value=>"1234", :regex=>/^!dataset_pubmed_id = (\d+)$/, :name=>"pubmed_id"}, {:value=>"", :regex=>/^!dataset_reference_series = (GSE\d+)$/, :name=>"reference_series"}, {:value=>"", :regex=>/^!dataset_platform = (GPL\d+)$/, :name=>"platform_geo_accession"}]
    end
  end

  describe "download" do
    it "should download the file if it doesn't exist" do
      ds = Factory.build(:dataset)
      File.should_receive(:exists?).with(/datafiles\/GSE8700\/GSE8700\.soft$/).and_return(false)
      ds.should_receive(:download_file).and_return(true)
      ds.download
    end
  end
  
  describe "dataset path" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.dataset_path.should match(/datafiles\/GSE8700$/)
    end
  end
  
  describe "dataset filename" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.dataset_filename.should == "GSE8700.soft"
    end
  end
  
  describe "local dataset filename" do
    it "should return the path for the datasets" do
      ds = Factory.build(:dataset)
      ds.local_dataset_filename.should match(/datafiles\/GSE8700\/GSE8700.soft$/)
    end
  end

  describe "page" do
    it "should call paginate" do
      Dataset.should_receive(:paginate).with({:conditions=>"conditions", :order => [:geo_accession], :page=>2, :per_page=>20}).and_return(true)
      Dataset.page("conditions", 2, 20)
    end
  end

end
