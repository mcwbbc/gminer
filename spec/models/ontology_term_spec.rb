require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OntologyTerm do

  describe "persist" do
    describe "with existing" do
      it "should not create" do
        ot = OntologyTerm.generate
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "term_id"}).and_return(ot)
        OntologyTerm.persist("term_id", "ncbo_id", "term_name").should == nil
      end
    end

    describe "without existing" do
      before(:each) do
        @ot = OntologyTerm.generate
        OntologyTerm.should_receive(:first).with(:conditions => {:term_id => "term_id"}).and_return(nil)
      end

      describe "with matching ontology" do
        it "should create a new ontology_term" do
          ontology = Ontology.generate
          Ontology.should_receive(:first).with(:conditions => {:ncbo_id => "ncbo_id"}).and_return(ontology)
          ontology_terms = mock("ontology_terms")
          ontology.should_receive(:ontology_terms).and_return(ontology_terms)
          ontology_terms.should_receive(:create).with(:term_id => "term_id", :ncbo_id => "ncbo_id", :name => "term_name").and_return(@ot)
          OntologyTerm.persist("term_id", "ncbo_id", "term_name").should == @ot
        end
      end

      describe "without matching ontology" do
        it "should not save anyting" do
          Ontology.should_receive(:first).with(:conditions => {:ncbo_id => "ncbo_id"}).and_return(nil)
          OntologyTerm.persist("term_id", "ncbo_id", "term_name").should be_nil
        end
      end

    end
  end

  describe "cloud" do
    it "should return ontology terms with empty options" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find_by_sql).with("SELECT ontology_terms.* FROM ontology_terms, ontologies WHERE ontology_terms.annotations_count > 0 GROUP BY ontology_terms.name ORDER BY ontology_terms.annotations_count DESC, ontology_terms.name").and_return([term])
      OntologyTerm.cloud.should == [term]
    end

    it "should return ontology terms with an ontology" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find_by_sql).with("SELECT ontology_terms.* FROM ontology_terms, ontologies WHERE ontology_terms.annotations_count > 0 AND ontology_terms.ncbo_id = ontologies.ncbo_id AND ontologies.name = 'Rat Strain Ontology' GROUP BY ontology_terms.name ORDER BY ontology_terms.annotations_count DESC, ontology_terms.name").and_return([term])
      OntologyTerm.cloud(:ontology => "Rat Strain Ontology").should == [term]
    end

    it "should return ontology terms with an ontology and limit" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find_by_sql).with("SELECT ontology_terms.* FROM ontology_terms, ontologies WHERE ontology_terms.annotations_count > 0 AND ontology_terms.ncbo_id = ontologies.ncbo_id AND ontologies.name = 'Rat Strain Ontology' GROUP BY ontology_terms.name ORDER BY ontology_terms.annotations_count DESC, ontology_terms.name LIMIT 5").and_return([term])
      OntologyTerm.cloud(:ontology => "Rat Strain Ontology", :limit => 5).should == [term]
    end
  end

  describe "page" do
    it "should call paginate" do
      OntologyTerm.should_receive(:paginate).with({:conditions=>"conditions", :order => [:name], :page=>2, :per_page=>20}).and_return(true)
      OntologyTerm.page("conditions", 2, 20)
    end
  end

  describe "child closures" do
    before(:each) do
      @ot = OntologyTerm.generate
    end

    it "should return and empty array for no closures" do
      AnnotationClosure.should_receive(:all).with(:conditions => {:ontology_term_id => @ot.id}, :order => "ontology_terms.name", :include => [:ontology_term]).and_return([])
      @ot.child_closures.should == []
    end

    it "should return an array of terms create by closure for this term" do
      term = mock(OntologyTerm)

      a = mock(Annotation)
      a.should_receive(:ontology_term).and_return(term)
      
      ac = mock(AnnotationClosure)
      ac.should_receive(:annotation).and_return(a)
      AnnotationClosure.should_receive(:all).with(:conditions => {:ontology_term_id => @ot.id}, :order => "ontology_terms.name", :include => [:ontology_term]).and_return([ac])

      @ot.child_closures.should == [term]
    end
  end

  describe "parent closures" do
    before(:each) do
      @ot = OntologyTerm.generate
    end

    it "should return and empty array for no annotations" do
      @ot.parent_closures.should == []
    end

    it "should return an array of terms create by closure for this term" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find_by_sql).with("SELECT DISTINCT ontology_terms.* FROM annotations, annotation_closures, ontology_terms WHERE annotations.ontology_term_id = #{@ot.id} AND annotations.id = annotation_closures.annotation_id AND ontology_terms.id = annotation_closures.ontology_term_id ORDER BY ontology_terms.name").and_return([term])
      @ot.parent_closures.should == [term]
    end
  end

  describe "closure geo references" do
    before(:each) do
      @ot = OntologyTerm.generate
    end

    it "should return an empty array with no annotations" do
      @ot.closure_geo_references.should == []
    end

    it "should return an array of hashes of geo references" do
      a = mock(Annotation)
      a.should_receive(:geo_accession).and_return("GSM1234")
      a.should_receive(:description).and_return("description")

      ac = mock(AnnotationClosure)
      ac.should_receive(:annotation).twice.and_return(a)

      @ot.should_receive(:annotation_closures).and_return([ac])
      @ot.closure_geo_references.should == [{:geo_accession=>"GSM1234", :description=>"description"}]
    end
  end

  describe "direct geo references" do
    before(:each) do
      @ot = OntologyTerm.generate
    end

    it "should return an empty array with no annotations" do
      @ot.direct_geo_references.should == []
    end

    it "should return an array of hashes of geo references" do
      a = mock(Annotation)
      a.should_receive(:geo_accession).and_return("GSM1234")
      a.should_receive(:description).and_return("description")

      @ot.should_receive(:annotations).and_return([a])
      @ot.direct_geo_references.should == [{:geo_accession=>"GSM1234", :description=>"description"}]
    end
  end

  describe "link item" do
    before(:each) do
      @ot = OntologyTerm.generate
      @item = mock("geo_item")
    end

    it "should return a sample" do
      @ot.link_item("GSM1234").should == "<a href='/samples/GSM1234'>GSM1234</a>"
    end

    it "should return a series" do
      @ot.link_item("GSE1234").should == "<a href='/series_item/GSE1234'>GSE1234</a>"
    end

    it "should return a platform" do
      @ot.link_item("GPL1234").should == "<a href='/platforms/GPL1234'>GPL1234</a>"
    end

    it "should return a dataset" do
      @ot.link_item("GDS1234").should == "<a href='/datasets/GDS1234'>GDS1234</a>"
    end
  end

  describe "to_param" do
    it "should return the term_id as the param" do
      ot = OntologyTerm.generate
      ot.to_param.should == "13578|Cheese"
    end
  end

  describe "valid annotation count" do
    it "should return a number of the valid annotations" do
      ot = OntologyTerm.generate
      Annotation.should_receive(:count).with(:conditions => {:ontology_term_id => ot.id, :verified => true} ).and_return(1)
      ot.valid_annotation_count.should == 1
    end
  end

  describe "audited annotation count" do
    it "should return a number of the audited annotations" do
      ot = OntologyTerm.generate
      Annotation.should_receive(:count).with(:conditions => {:ontology_term_id => ot.id, :audited => true} ).and_return(1)
      ot.audited_annotation_count.should == 1
    end
  end

  describe "valid_annotation_percentage" do
    it "should return a percentage of the valid annotations" do
      @ot = OntologyTerm.generate(:annotations_count => 2)
      @ot.should_receive(:valid_annotation_count).and_return(1)
      @ot.valid_annotation_percentage.should == 50.0
    end

    it "should return 0 if there are no valid" do
      @ot = OntologyTerm.generate(:annotations_count => 0)
      @ot.valid_annotation_percentage.should == 0
    end
  end

  describe "audited_annotation_percentage" do
    it "should return a percentage of the audited annotations" do
      @ot = OntologyTerm.generate(:annotations_count => 2)
      @ot.should_receive(:audited_annotation_count).and_return(1)
      @ot.audited_annotation_percentage.should == 50.0
    end

    it "should return 0 if there are no valid" do
      @ot = OntologyTerm.generate(:annotations_count => 0)
      @ot.audited_annotation_percentage.should == 0
    end
  end
end
