require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Sample do

  describe "persist" do
    it "should set the fields and save to the database" do
      p = Factory.build(:sample)
      p.stub!(:sample_hash).and_return({"organism" => "rat"})
      p.should_receive(:save!).and_return(true)
      p.persist
    end
  end

  describe "sample hash" do
    it "should return the hash for the sample by parsing the file" do
      p = Factory.build(:sample)
      p.should_receive(:fields).and_return(["fields"])
      p.should_receive(:local_sample_filename).and_return("file.soft")
      p.should_receive(:file_hash).with(["fields"], "file.soft").and_return({:geo_accession => "GSM1234", :series_geo_accession => "GSE8700", :platform_geo_accession => "GPL1355", :organism => "rat"})
      p.sample_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      p = Factory.build(:sample)
      p.fields.should == [{:value=>"Sample Title", :regex=>/^!Sample_title = (.+)$/, :name=>"title"}, {:value=>"sample_type", :regex=>/^!Sample_type = (.+?)$/, :name=>"sample_type"}, {:value=>"source_name", :regex=>/^!Sample_source_name_ch1 = (.+?)$/, :name=>"source_name"}, {:value=>"rat", :regex=>/^!Sample_organism_ch1 = (.+?)$/, :name=>"organism"}, {:value=>"characteristics", :regex=>/^!Sample_characteristics_ch1 = (.+?)$/, :name=>"characteristics"}, {:value=>"treatment_protocol", :regex=>/^!Sample_treatment_protocol_ch1 = (.+?)$/, :name=>"treatment_protocol"}, {:value=>"extract_protocol", :regex=>/^!Sample_extract_protocol_ch1 = (.+?)$/, :name=>"extract_protocol"}, {:value=>"label", :regex=>/^!Sample_label_ch1 = (.+?)$/, :name=>"label"}, {:value=>"label_protocol", :regex=>/^!Sample_label_protocol_ch1 = (.+?)$/, :name=>"label_protocol"}, {:value=>"scan_protocol", :regex=>/^!Sample_scan_protocol = (.+?)$/, :name=>"scan_protocol"}, {:value=>"hyp_protocol", :regex=>/^!Sample_hyb_protocol = (.+?)$/, :name=>"hyp_protocol"}, {:value=>"description", :regex=>/^!Sample_description = (.+?)$/, :name=>"description"}, {:value=>"data_processing", :regex=>/^!Sample_data_processing = (.+?)$/, :name=>"data_processing"}, {:value=>"molecule", :regex=>/^!Sample_molecule_ch1 = (.+?)$/, :name=>"molecule"}]
    end
  end
  
  describe "series path" do
    it "should return the path for the series" do
      p = Factory.build(:sample)
      p.series_path.should match(/datafiles\/GPL1355\/GSE8700$/)
    end
  end
  
  describe "sample filename" do
    it "should return the path for the samples" do
      p = Factory.build(:sample)
      p.local_sample_filename.should match(/datafiles\/GPL1355\/GSE8700\/GSM1234_sample.soft$/)
    end
  end
  
  describe "page" do
    it "should call paginate" do
      Sample.should_receive(:paginate).with({:conditions=>"conditions", :order => [:geo_accession], :page=>2, :per_page=>20}).and_return(true)
      Sample.page("conditions", 2, 20)
    end
  end

  describe "create detections" do
    it "should create detections from the sample file" do
      array = [
"#ID_REF = ",
"#VALUE = MAS5-calculated Signal intensity",
"#ABS_CALL = the call in an absolute analysis that indicates if the transcript was present (P), absent (A), marginal (M), or no call (NC)",
"#DETECTION P-VALUE = 'detection p-value', p-value that indicates the significance level of the detection call",
"!sample_table_begin",
"ID_REF	VALUE	ABS_CALL	DETECTION P-VALUE",
"AFFX-BioB-5_at	3893.9	P	0.00034",
"AFFX-BioB-M_at	5571.1	P	0.000044",
"!sample_table_end"
              ]
      s = Factory.build(:sample)
      s.stub!(:id).and_return(1)
      File.should_receive(:open).with(/datafiles\/GPL1355\/GSE8700\/GSM1234_sample.soft/, "r").and_return(array)
      sql = "INSERT INTO detections (sample_geo_accession, id_ref, abs_call) VALUES ('GSM1234', 'AFFX-BioB-5_at', 'P'), ('GSM1234', 'AFFX-BioB-M_at', 'P')"

#      insert = repository(:default).adapter.execute(sql)
#      adapter = mock("Adapter", :name => "MySQLAdapter")
#      adapter.should_receive(:execute).with(sql).and_return(true)
#      DataMapper.should_receive(:repository).with(:default).and_return(adapter)
      s.create_detections
    end

    it "should not create detections from an empty sample file" do
      array = []
      s = Factory.build(:sample)
      File.should_receive(:open).with(/datafiles\/GPL1355\/GSE8700\/GSM1234_sample.soft/, "r").and_return(array)
      s.create_detections
    end
  end

  describe "create results" do
    before(:each) do
      @detection = mock(Detection, :abs_call => "P", :id_ref => "abc")
      @detections = mock("detections")
      @sample = mock(Sample, :geo_accession => "GSM1234", :pubmed_id => "1234", :ontology_term_id => "rs:1234", :detections => @detections)
      Sample.stub!(:matching).and_return([@sample])
    end

    it "should create results for each of the samples and detections" do
      Detection.should_receive(:all).with(:sample_geo_accession => "GSM1234", :abs_call => 'P').and_return([@detection])
      sql = "INSERT INTO results (sample_geo_accession, id_ref, pubmed_id, ontology_term_id) VALUES ('GSM1234', 'abc', '1234', 'rs:1234')"
      Sample.create_results(:term => "kidney")
    end

    it "should not create results for empty inserts" do
      Detection.should_receive(:all).with(:sample_geo_accession => "GSM1234", :abs_call => 'P').and_return([])
      Sample.create_results(:term => "nothing")
    end

    it "should catch exception on duplicate insert" do
      Detection.should_receive(:all).with(:sample_geo_accession => "GSM1234", :abs_call => 'P').and_return([@detection])
      sql = "INSERT INTO results (sample_geo_accession, id_ref, pubmed_id, ontology_term_id) VALUES ('GSM1234', 'abc', '1234', 'rs:1234')"
      Sample.create_results(:term => "nothing")
    end

#    it "should catch exception on other error" do
#      @detections.should_receive(:find).with(:all, :conditions => {:abs_call => 'P'}).and_return([@detection])
#      sql = "INSERT INTO results (sample_geo_accession, id_ref, pubmed_id, ontology_term_id) VALUES ('GSM1234', 'abc', '1234', 'rs:1234')"
#      DataMapper.repository(:default).adapter.execute(sql)
#     adapter = mock("Adapter")
#      DataMapper.should_receive(:repository).with(:default).and_return(adapter)
#      lambda { Sample.create_results(:term => "nothing") }.should raise_error
#    end

  end

  describe "matching" do
    it "should return the series geo accessions and pubmed_ids for samples matching the params" do
      sample = mock(Sample)
      sql = "SELECT samples.geo_accession, series_items.pubmed_id as pubmed_id, ontology_terms.term_id as ontology_term_id FROM samples, ontology_terms, series_items, annotations, ontologies WHERE ontology_terms.name = 'kidney' AND ontologies.name = '' AND ontology_terms.ncbo_id = ontologies.ncbo_id AND annotations.field = '' AND series_items.pubmed_id != '' AND samples.series_geo_accession = series_items.geo_accession AND annotations.ontology_term_id = ontology_terms.term_id AND annotations.geo_accession = samples.geo_accession GROUP BY samples.geo_accession"
      repository(:default).adapter.should_receive(:query).with(sql).and_return([sample])
      Sample.matching({:term => "kidney"}).should == [sample]
    end
  end

end
