require 'spec_helper'

describe OntologyTerm do

  describe "cloud_term_ids" do
    it "should return ontology terms with empty options" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find).with(:all, {:order=>'name', :joins=>"INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1", :select=>"ontology_terms.term_id, ontology_terms.name, count(DISTINCT geo_accession) AS annotations_count", :group=>'ontology_terms.term_id', :limit=>nil}).and_return([term])
      OntologyTerm.cloud_term_ids.should == [term]
    end

    it "should return ontology terms with an ontology" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find).with(:all, {:order=>'name', :joins=>"INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.ncbo_id = '1150'", :select=>"ontology_terms.term_id, ontology_terms.name, count(DISTINCT geo_accession) AS annotations_count", :group=>'ontology_terms.term_id', :limit=>nil}).and_return([term])
      OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1150").should == [term]
    end

    it "should return ontology terms with an ontology and limit" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find).with(:all, {:order=>'annotations_count DESC', :joins=>"INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.ncbo_id = '1150'", :select=>"ontology_terms.term_id, ontology_terms.name, count(DISTINCT geo_accession) AS annotations_count", :group=>'ontology_terms.term_id', :limit=>5}).and_return([term])
      OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1150", :limit => 5).should == [term]
    end

    it "should return ontology terms with an ontology and limit returning everything" do
      term = mock(OntologyTerm)
      OntologyTerm.should_receive(:find).with(:all, {:order=>'annotations_count DESC', :joins=>"INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.ncbo_id = '1150' AND annotations.geo_accession IN ('1000|MA:0001')", :select=>"ontology_terms.term_id, ontology_terms.name, count(DISTINCT geo_accession) AS annotations_count", :group=>'ontology_terms.term_id', :limit=>5}).and_return([term])
      OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1150", :limit => 5, :geo_term_array => ["1000|MA:0001"]).should == [term]
    end
  end

  describe "page" do
    it "should call paginate" do
      join = "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1"
      OntologyTerm.should_receive(:paginate).with({:conditions=>"conditions", :joins => join, :group => 'annotations.term_id', :order => 'name', :page => 2, :per_page => 20}).and_return(true)
      OntologyTerm.page("conditions", 2, 20)
    end
  end

  describe "child closures" do
    before(:each) do
      @ot = Factory.build(:ontology_term)
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
      @ot = Factory.build(:ontology_term, :id => 1)
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
      @ot = Factory.build(:ontology_term)
    end

    it "should return an empty array with no annotations" do
      @ot.closure_geo_references.should == []
    end

    it "should return an array of hashes of geo references" do
      a = mock(Annotation, :field_name => 'description')
      a.should_receive(:geo_accession).and_return("GSM1234")
      a.should_receive(:description).and_return("funny thing")

      b = mock(Annotation, :field_name => 'title')
      b.should_receive(:geo_accession).and_return("GSM1234")
      b.should_receive(:description).and_return("funny thing")

      c = mock(Annotation, :field_name => 'title')
      c.should_receive(:geo_accession).and_return("GSM1235")
      c.should_receive(:description).and_return("other")

      ac = mock(AnnotationClosure)
      ac.should_receive(:annotation).twice.and_return(a)

      ac2 = mock(AnnotationClosure)
      ac2.should_receive(:annotation).twice.and_return(b)

      ac3 = mock(AnnotationClosure)
      ac3.should_receive(:annotation).twice.and_return(c)

      @ot.should_receive(:valid_annotation_closures).and_return([ac, ac2, ac3])
      @ot.closure_geo_references.should == [{:geo_accession=>"GSM1234", :description=>"funny thing"}, {:geo_accession=>"GSM1235", :description=>"other"}]
    end
  end

  describe "direct geo references" do
    before(:each) do
      @ot = Factory.build(:ontology_term)
    end

    it "should return an empty array with no annotations" do
      @ot.direct_geo_references.should == []
    end

    it "should return a unique array of hashes of geo references" do
      a = mock(Annotation, :field_name => 'description')
      a.should_receive(:geo_accession).and_return("GSM1234")
      a.should_receive(:description).and_return("funny thing")

      b = mock(Annotation, :field_name => 'title')
      b.should_receive(:geo_accession).and_return("GSM1234")
      b.should_receive(:description).and_return("funny thing")

      c = mock(Annotation, :field_name => 'title')
      c.should_receive(:geo_accession).and_return("GSM1235")
      c.should_receive(:description).and_return("other")

      @ot.should_receive(:valid_annotations).and_return([a,b,c])
      @ot.direct_geo_references.should == [{:description=>"funny thing", :geo_accession=>"GSM1234"}, {:description=>"other", :geo_accession=>"GSM1235"}]
    end
  end

  describe "link item" do
    before(:each) do
      @ot = Factory.build(:ontology_term)
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
      ot = Factory.build(:ontology_term)
      ot.to_param.should == ot.term_id
    end
  end

  describe "specific_term_id" do
    it "should return the term_id without the ncbo ontology id" do
      ot = Factory.build(:ontology_term)
      ot.specific_term_id.should == ot.term_id.split("|").last
    end
  end

  describe "valid annotation count" do
    it "should return a number of the valid annotations" do
      ot = Factory.build(:ontology_term)
      Annotation.should_receive(:count).with(:conditions => {:ontology_term_id => ot.id, :verified => true} ).and_return(1)
      ot.valid_annotation_count.should == 1
    end
  end

  describe "audited annotation count" do
    it "should return a number of the audited annotations" do
      ot = Factory.build(:ontology_term)
      Annotation.should_receive(:count).with(:conditions => {:ontology_term_id => ot.id, :status => 'audited'} ).and_return(1)
      ot.audited_annotation_count.should == 1
    end
  end

  describe "valid_annotation_percentage" do
    it "should return a percentage of the valid annotations" do
      @ot = Factory.build(:ontology_term, :annotations_count => 2)
      @ot.should_receive(:valid_annotation_count).and_return(1)
      @ot.valid_annotation_percentage.should == 50.0
    end

    it "should return 0 if there are no valid" do
      @ot = Factory.build(:ontology_term, :annotations_count => 0)
      @ot.valid_annotation_percentage.should == 0
    end
  end

  describe "audited_annotation_percentage" do
    it "should return a percentage of the audited annotations" do
      @ot = Factory.build(:ontology_term, :annotations_count => 2)
      @ot.should_receive(:audited_annotation_count).and_return(1)
      @ot.audited_annotation_percentage.should == 50.0
    end

    it "should return 0 if there are no valid" do
      @ot = Factory.build(:ontology_term, :annotations_count => 0)
      @ot.audited_annotation_percentage.should == 0
    end
  end

  describe "geo counts" do
    it "should return an array of the geo type and the number of annotations for the term for that type" do
      @ot = Factory.build(:ontology_term)
      annotations = mock()
      annotations.should_receive(:count).exactly(4).times.and_return(1,2,3,4)
      @ot.should_receive(:annotations).exactly(4).times.and_return(annotations)
      @ot.geo_counts.should == [["Platform", 1], ["Dataset", 2], ["Series", 3], ["Sample", 4]]
    end

    it "should return an array of the geo type and the number of annotations for the term for that type" do
      @ot = Factory.build(:ontology_term)
      @ot.geo_counts.should == []
    end
  end

end
