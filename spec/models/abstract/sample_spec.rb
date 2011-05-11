require 'spec_helper'

describe Abstract::Sample do

  describe "persist" do
    it "should set the fields and save to the database" do
      s = Factory.build(:sample)
      s.stub!(:sample_hash).and_return({"organism" => "rat"})
      s.should_receive(:save!).and_return(true)
      s.persist
    end
  end

  describe "sample hash" do
    it "should return the hash for the sample by parsing the file" do
      s = Factory.build(:sample)
      s.should_receive(:field_array).and_return(["fields"])
      s.should_receive(:local_sample_filename).and_return("file.soft")
      s.should_receive(:file_hash).with(["fields"], "file.soft").and_return({:geo_accession => "GSM1234", :series_geo_accession => "GSE8700", :platform_geo_accession => "GPL1355", :organism => "rat"})
      s.sample_hash
    end
  end

  describe "fields" do
    it "should return an array of hashes with field information" do
      s = Factory.build(:sample)
      s.field_array.should == [{:value=>"Sample Title", :regex=>/^!Sample_title = (.+)$/, :name=>"title", :annotatable=>true}, {:value=>"sample_type", :regex=>/^!Sample_type = (.+?)$/, :name=>"sample_type", :annotatable=>true}, {:value=>"source_name", :regex=>/^!Sample_source_name_ch1 = (.+?)$/, :name=>"source_name", :annotatable=>true}, {:value=>"rat", :regex=>/^!Sample_organism_ch1 = (.+?)$/, :name=>"organism", :annotatable=>true}, {:value=>"characteristics", :regex=>/^!Sample_characteristics_ch1 = (.+?)$/, :name=>"characteristics", :annotatable=>true}, {:value=>"treatment_protocol", :regex=>/^!Sample_treatment_protocol_ch1 = (.+?)$/, :name=>"treatment_protocol", :annotatable=>true}, {:value=>"extract_protocol", :regex=>/^!Sample_extract_protocol_ch1 = (.+?)$/, :name=>"extract_protocol", :annotatable=>true}, {:value=>"label", :regex=>/^!Sample_label_ch1 = (.+?)$/, :name=>"label", :annotatable=>true}, {:value=>"label_protocol", :regex=>/^!Sample_label_protocol_ch1 = (.+?)$/, :name=>"label_protocol", :annotatable=>true}, {:value=>"scan_protocol", :regex=>/^!Sample_scan_protocol = (.+?)$/, :name=>"scan_protocol", :annotatable=>true}, {:value=>"hyp_protocol", :regex=>/^!Sample_hyb_protocol = (.+?)$/, :name=>"hyp_protocol", :annotatable=>true}, {:value=>"description", :regex=>/^!Sample_description = (.+?)$/, :name=>"description", :annotatable=>true}, {:value=>"data_processing", :regex=>/^!Sample_data_processing = (.+?)$/, :name=>"data_processing", :annotatable=>true}, {:value=>"molecule", :regex=>/^!Sample_molecule_ch1 = (.+?)$/, :name=>"molecule", :annotatable=>true}]
    end
  end

  describe "series path" do
    it "should return the path for the series" do
      p = Factory.build(:platform)
      si = Factory.build(:series_item)
      s = Factory.build(:sample, :platform => p, :series_item => si)
      s.series_path.should match(/datafiles\/GPL1355\/GSE8700$/)
    end
  end

  describe "sample filename" do
    it "should return the path for the samples" do
      p = Factory.build(:platform)
      si = Factory.build(:series_item)
      s = Factory.build(:sample, :platform => p, :series_item => si)
      s.local_sample_filename.should match(/datafiles\/GPL1355\/GSE8700\/GSM1234_sample.soft$/)
    end
  end

  describe "to_param" do
    it "should return the geo_accession as the param" do
      s = Factory.build(:sample)
      s.to_param.should == "GSM1234"
    end
  end
end
