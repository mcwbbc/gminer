require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Annotation do

  describe "build cloud" do
    before(:each) do
      @at1 = mock(OntologyTerm, :name => "at1", :term_id => "at1_id")
      @at2 = mock(OntologyTerm, :name => "at2", :term_id => "at2_id")

      @rs1 = mock(OntologyTerm, :name => "rs1", :term_id => "rs1_id")
      @rs2 = mock(OntologyTerm, :name => "rs2", :term_id => "rs2_id")

      @a1 = mock(Annotation, :geo_accession => "GSM1", :description => "a1_desc")
      @a2 = mock(Annotation, :geo_accession => "GSM2", :description => "a2_desc")
      @anatomy_terms = [@at1, @at2]
      @rat_strain_terms = [@rs1, @rs2]
      @annotations = [@a1, @a2]
      OntologyTerm.should_receive(:cloud).with(:ontology => "Mouse adult gross anatomy").and_return(@anatomy_terms)
      OntologyTerm.should_receive(:cloud).with(:ontology => "Rat Strain Ontology").and_return(@rat_strain_terms)
      Annotation.should_receive(:find_by_sql).with("SELECT * FROM annotations GROUP BY geo_accession ORDER BY geo_accession").and_return(@annotations)
    end

    describe "with no parameters" do
      it "should return the annotation hash, anatomy terms and rat strain terms" do
        @annotation_hash = {"GSM1"=>"a1_desc", "GSM2"=>"a2_desc"}
        Annotation.build_cloud(nil).should == [@annotation_hash, @anatomy_terms, @rat_strain_terms]
      end
    end

    describe "with parameters" do
      it "should return the filtered annotation hash, anatomy terms and rat strain terms" do
        Annotation.should_receive(:find_by_sql).with("SELECT * FROM annotations WHERE ontology_term_id = 'term_id' GROUP BY geo_accession ORDER BY geo_accession").and_return([@a2])
        a1 = mock(Annotation, :ontology_term_id => "rs2_id")
        annotations = [a1]
        item = mock("item", :annotations => annotations)
        Annotation.should_receive(:load_item).with("GSM2").and_return(item)
        @annotation_hash = {"GSM2"=>"a2_desc"}
        @anatomy_terms = []
        @rat_strain_terms = [@rs2]
        Annotation.build_cloud(["term_id"]).should == [@annotation_hash, @anatomy_terms, @rat_strain_terms]
      end
    end
  end

  describe "create for" do
    it "should skip creating the annotation if it exists for the geo accession and field" do
      hash =  {"MGREP" => {"39234|RS:0000457"=>{:name=>"rat strain", :from => "1", :to => "10"}}, "ISA_CLOSURE"=>{}}
      annotation = mock(Annotation)
      Annotation.should_receive(:first).with(:geo_accession => "GSM1234", :field => "fname").and_return(annotation)
      Annotation.create_for("GSM1234", [{:name => "fname", :value => "fvalue"}], "desc").should == [{:name => "fname", :value => "fvalue"}]
    end

    it "should save an annotation if returned by the ncbo service" do
      hash =  {"MGREP" => {"39234|RS:0000457"=>{:name=>"rat strain", :from => "1", :to => "10"}}, "ISA_CLOSURE"=>{}}
      ontology = mock(Ontology)
      ontology.should_receive(:ncbo_id).and_return("1234")
      Ontology.should_receive(:all).and_return([ontology])
      NCBOService.should_receive(:result_hash).with("fvalue", "1234").and_return(hash)
      Annotation.should_receive(:first).with(:geo_accession => "GSM1234", :field => "fname").and_return(nil)
      Annotation.should_receive(:process_ncbo_results).with(hash, "GSM1234", "fname", "desc").and_return(true)
      Annotation.create_for("GSM1234", [{:name => "fname", :value => "fvalue"}], "desc").should == [{:name => "fname", :value => "fvalue"}]
    end
  end

  describe "process closure" do
    it "should create annotation closures" do
      hash = {
        "MSH|C0003062"=> [
          {:name => "MeSH Descriptors", :id => "MSH|C1256739"}
          ],
        "MSH|C0034721"=> [
          {:name => "Animals", :id => "MSH|C0003062"},
          {:name => "Vertebrates", :id => "MSH|C0042567"},
          {:name => "MeSH Descriptors", :id => "MSH|C1256739"}
          ]
      }

      c1 = mock("closures1")
      c1.should_receive(:create).with(:ontology_term_id => "MSH|C1256739").and_return(true)
      c2 = mock("closures2")
      c2.should_receive(:create).with(:ontology_term_id => "MSH|C1256739").and_return(true)
      c2.should_receive(:create).with(:ontology_term_id => "MSH|C0003062").and_return(true)
      c2.should_receive(:create).with(:ontology_term_id => "MSH|C0042567").and_return(true)

      a1 = mock(Annotation, :id => 1)
      a1.should_receive(:annotation_closures).and_return(c1)
      a2 = mock(Annotation, :id => 2)
      a2.should_receive(:annotation_closures).exactly(3).times.and_return(c2)

      Annotation.should_receive(:first).with(:geo_accession => "GSM1234", :field => "fname", :ontology_term_id => "MSH|C0003062").and_return(a1)
      Annotation.should_receive(:first).with(:geo_accession => "GSM1234", :field => "fname", :ontology_term_id => "MSH|C0034721").and_return(a2)
      
      Annotation.process_closure(hash, "GSM1234", "fname")
    end
  end

  describe "process mgrep" do
    it "should create annotations" do
      hash = {
        "MSH|C0003062"=>{:name=>"Animals", :from => "19", :to => "25"},
        "MSH|C0034693"=>{:name=>"Rattus norvegicus", :from => "1", :to => "17"},
        "MSH|C0034721"=>{:name=>"Rattus", :from => "1", :to => "6"}
      }

      Annotation.should_receive(:save_term).with("MSH|C0003062", "MSH", "Animals").and_return(true)
      Annotation.should_receive(:save_term).with("MSH|C0034693", "MSH", "Rattus norvegicus").and_return(true)
      Annotation.should_receive(:save_term).with("MSH|C0034721", "MSH", "Rattus").and_return(true)
      a = mock(Annotation, :save => true)
      Annotation.should_receive(:new).with({:geo_accession=>"GSM1234", :field=>"fname", :ncbo_id => "MSH", :ontology_term_id=>"MSH|C0003062", :from => "19", :to => "25", :description => "desc"}).and_return(a)
      Annotation.should_receive(:new).with({:geo_accession=>"GSM1234", :field=>"fname", :ncbo_id => "MSH", :ontology_term_id=>"MSH|C0034693", :from => "1", :to => "17", :description => "desc"}).and_return(a)
      Annotation.should_receive(:new).with({:geo_accession=>"GSM1234", :field=>"fname", :ncbo_id => "MSH", :ontology_term_id=>"MSH|C0034721", :from => "1", :to => "6", :description => "desc"}).and_return(a)
      Annotation.process_mgrep(hash, "GSM1234", "fname", "desc")
    end

    it "should create an empty annotation if we didn't get back any results" do
      hash = {}
      a = mock(Annotation, :save => true)
      Annotation.should_receive(:new).with({:geo_accession=>"GSM1234", :field=>"fname", :ncbo_id => "none", :ontology_term_id=>"none", :from => "0", :to => "0"}).and_return(a)
      Annotation.process_mgrep(hash, "GSM1234", "fname", "desc")
    end
  end


  describe "save term" do
    it "should create a new term if it doesn't exist" do
      ot = mock(OntologyTerm)
      ot.should_receive(:save).and_return(true)
      OntologyTerm.should_receive(:first).with(:term_id => "key").and_return(nil)
      OntologyTerm.should_receive(:new).with(:term_id => "key", :ncbo_id => "ncbo_id", :name => "term_name").and_return(ot)
      Annotation.save_term("key", "ncbo_id", "term_name").should be_true
    end

    it "should not create a new term if it exists" do
      ot = mock(OntologyTerm)
      OntologyTerm.should_receive(:first).with(:term_id => "key").and_return(ot)
      Annotation.save_term("key", "ncbo_id", "term_name").should == nil
    end
  end

  describe "process ncbo results" do
    it "should process the hash" do
      Annotation.should_receive(:transaction).and_yield
      Annotation.should_receive(:process_mgrep).with({:mg => "value"}, "GPL1234", "summary", "desc").and_return(true)
      Annotation.should_receive(:process_closure).with({:cl => "value"}, "GPL1234", "summary").and_return(true)
      Annotation.process_ncbo_results({"MGREP" => {:mg => "value"}, "ISA_CLOSURE" => {:cl => "value"}}, "GPL1234", "summary", "desc")
    end
  end

  describe "count by ontology array" do
    it "should return an array of ontologies and the number of annotations for each" do
      Annotation.stub!(:count).and_return(1)
      Annotation.count_by_ontology_array.should == [{:amount=>1, :name=>"Mouse adult gross anatomy"}, {:amount=>1, :name=>"Medical Subject Headings, 2009_2008_08_06"}, {:amount=>1, :name=>"Pathway Ontology"}, {:amount=>1, :name=>"Biological process"}, {:amount=>1, :name=>"NCI Thesaurus"}, {:amount=>1, :name=>"Molecular function"}, {:amount=>1, :name=>"Cellular component"}, {:amount=>1, :name=>"Rat Strain Ontology"}, {:amount=>1, :name=>"Mammalian Phenotype"}]
    end
  end

  describe "page" do
    it "should call paginate" do
      Annotation.should_receive(:paginate).with({:order =>[DataMapper::Query::Direction.new(OntologyTerm.properties[:name], :asc)], :conditions=>"conditions", :page=>2, :links=>[:ontology_term, :ontology], :per_page=>20}).and_return(true)
      Annotation.page("conditions", 2, 20)
    end
  end

end