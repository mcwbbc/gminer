require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
        Annotation.should_receive(:find_by_sql).with("SELECT annotations.* FROM annotations, ontology_terms WHERE ontology_terms.term_id = 'term_id' AND ontology_terms.id = annotations.ontology_term_id GROUP BY geo_accession ORDER BY geo_accession").and_return([@a2])
        ontology_term = mock(OntologyTerm, :term_id => "rs2_id")
        a1 = mock(Annotation, :ontology_term => ontology_term)
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

  describe "persist" do
    describe "without valid ontology term" do
      it "should not create a new annotation" do
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "term"}).and_return(nil)
        Annotation.persist("GPL1234", "title", "ncbo_id", "term", "0", "10", "description").should == nil
      end
    end

    describe "with valid ontology term" do
      before(:each) do
        @ontology = Ontology.generate
        @ontology_term = OntologyTerm.generate(:ontology_id => @ontology.id)
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "term"}).and_return(@ontology_term)
      end

      describe "with existing annotation" do
        it "should not create a new annotation" do
          annotation = Annotation.generate
          Annotation.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234", :field => "title", :ontology_term_id => @ontology_term.id}).and_return(annotation)
          Annotation.persist("GPL1234", "title", "ncbo_id", "term", "0", "10", "description").should == nil
        end
      end

      describe "without existing annotation" do
        it "should create a new annotation" do
          annotation = Annotation.generate
          Annotation.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234", :field => "title", :ontology_term_id =>  @ontology_term.id}).and_return(nil)
          Annotation.should_receive(:create).with(:geo_accession => "GPL1234", :field => "title", :ncbo_id => "ncbo_id", :ontology_id => @ontology_term.ontology.id, :ontology_term_id =>  @ontology_term.id, :from => "0", :to => "10", :description => "description").and_return(annotation)
          Annotation.persist("GPL1234", "title", "ncbo_id", "term", "0", "10", "description").should == annotation
        end
      end
    end
  end

  describe "count by ontology array" do
    it "should return an array of ontologies and the number of annotations for each" do
      Annotation.stub!(:count).and_return(1)
      Annotation.count_by_ontology_array.should == [{:name=>"Mouse adult gross anatomy", :amount=>1}, {:name=>"Medical Subject Headings, 2009_2008_08_06", :amount=>1}, {:name=>"Basic Vertebrate Anatomy", :amount=>1}, {:name=>"Pathway Ontology", :amount=>1}, {:name=>"NCI Thesaurus", :amount=>1}, {:name=>"Gene Ontology", :amount=>1}, {:name=>"Rat Strain Ontology", :amount=>1}, {:name=>"Mammalian Phenotype", :amount=>1}]
    end
  end

  describe "page" do
    it "should call paginate" do
      Annotation.should_receive(:paginate).with({:order => "ontology_terms.name", :conditions=>"conditions", :page=>2, :include => [:ontology_term, :ontology], :per_page=>20}).and_return(true)
      Annotation.page("conditions", 2, 20)
    end
  end

  describe "toggle" do
    describe "with verified" do
      it "should unverify it" do
        annotation = Annotation.spawn(:verified => true)
        annotation.should_receive(:save).and_return(true)
        annotation.toggle
        annotation.audited.should == true
        annotation.verified.should == false
      end
    end

    describe "with unverified" do
      it "should verify it" do
        annotation = Annotation.spawn(:verified => false)
        annotation.should_receive(:save).and_return(true)
        annotation.toggle
        annotation.audited.should == true
        annotation.verified.should == true
      end
    end
  end

  describe "in context" do
    data = { "amygdala" => {:full => "brain, amygdala", :context => "brain, <strong class='highlight'>amygdala</strong>", :from => 8, :to => 15},
             "articular cartilage" => {:full => "Knee articular cartilage, 4 weeks following sham surgery and more text to extend this out further", :context => "Knee <strong class='highlight'>articular cartilage</strong>, 4 weeks following sham surgery and more text to e...", :from => 6, :to => 24},
             "pancreatic lymph node" => {:full => "BB Rat day 65 female diabetic prone mast cells from pancreatic lymph node", :context => "...Rat day 65 female diabetic prone mast cells from <strong class='highlight'>pancreatic lymph node</strong>", :from => 53, :to => 73},
             "cheese" => {:full => "more text in front more text in front this is something in the middle of cheese and this is the long text at the end more text in end more text in end", :context => "...text in front this is something in the middle of <strong class='highlight'>cheese</strong> and this is the long text at the end more text in ...", :from => 74, :to => 79},
             "special" => {:full => "more text in front more text in front more text in front this is something in the middle of special ending", :context => "...text in front this is something in the middle of <strong class='highlight'>special</strong> ending", :from => 93, :to => 99},
           }

    data.keys.each do |key|
      it "should return the annotation within a context to determine if it's valid for #{key}" do
        hash = data[key]
        a = Annotation.spawn(:from => hash[:from], :to => hash[:to] )
        a.stub!(:field_value).and_return(hash[:full])
        a.in_context.should == hash[:context]
      end
    end
  end

  describe "full_text_highlighted" do
    data = { "amygdala" => {:full => "brain, amygdala", :full_hightlighted => "brain, <strong class='highlight'>amygdala</strong>", :from => 8, :to => 15},
             "articular cartilage" => {:full => "Knee articular cartilage, 4 weeks following sham surgery", :full_hightlighted => "Knee <strong class='highlight'>articular cartilage</strong>, 4 weeks following sham surgery", :from => 6, :to => 24},
             "pancreatic lymph node" => {:full => "BB Rat day 65 female diabetic prone mast cells from pancreatic lymph node", :full_hightlighted => "BB Rat day 65 female diabetic prone mast cells from <strong class='highlight'>pancreatic lymph node</strong>", :from => 53, :to => 73},
             "cheese" => {:full => "this is something in the middle of cheese and this is the long text at the end", :full_hightlighted => "this is something in the middle of <strong class='highlight'>cheese</strong> and this is the long text at the end", :from => 36, :to => 41},
             "special" => {:full => "special something in the middle of ending", :full_hightlighted => "<strong class='highlight'>special</strong> something in the middle of ending", :from => 1, :to => 7},
           }

    data.keys.each do |key|
      it "should return the full text of the annotation highlighted for #{key}" do
        hash = data[key]
        a = Annotation.spawn(:from => hash[:from], :to => hash[:to] )
        a.stub!(:field_value).and_return(hash[:full])
        a.full_text_highlighted.should == hash[:full_hightlighted]
      end
    end
  end


  describe "field_value" do
    it "should return the value of a field for the loaded item" do
      sample = Sample.spawn(:geo_accession => "GSM1234")
      annotation = Annotation.spawn(:field => "title", :geo_accession => "GSM1234")
      Annotation.should_receive(:load_item).with("GSM1234").and_return(sample)
      sample.should_receive(:send).with("title").and_return("field_value")
      annotation.field_value.should == "field_value"
    end
  end


end