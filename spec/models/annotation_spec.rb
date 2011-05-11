require 'spec_helper'

describe Annotation do

  describe "for_item" do
    it "should create a new annotation" do
      dataset = Factory.build(:dataset)
      annotation = Annotation.new(:created_by_id => "12", :curated_by_id => "12", :field_name => nil, :from => nil, :to => nil, :status => 'audited', :verified => true, :description => "rat strain dataset", :geo_accession => "GDS8700")
      Annotation.for_item(dataset, "12").should be_instance_of(Annotation)
    end
  end

  describe "geo_items" do
    describe "with one term" do
      it "should return annotations and the geo ids" do
        a1 = Factory.build(:annotation, :geo_accession => "GSM1")
        a2 = Factory.build(:annotation, :geo_accession => "GSM2")
        Annotation.should_receive(:find_by_sql).with("SELECT * FROM ((SELECT DISTINCT geo_accession, description FROM annotations INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.term_id = '1000|MA:0001')) AS tmp GROUP BY tmp.geo_accession HAVING COUNT(*) = 1").and_return([a1, a2])
        Annotation.geo_items(["1000|MA:0001"], 1).should == [0, [a1, a2], ["GSM1", "GSM2"]]
      end
    end

    describe "with multiple terms" do
      it "should return annotations and the geo ids" do
        a3 = Factory.build(:annotation, :geo_accession => "GSM3")
        a4 = Factory.build(:annotation, :geo_accession => "GSM4")
        Annotation.should_receive(:find_by_sql).with("SELECT * FROM ((SELECT DISTINCT geo_accession, description FROM annotations INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.term_id = '1000|MA:0001') UNION ALL (SELECT DISTINCT geo_accession, description FROM annotations INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.term_id = '1150|RS:1234')) AS tmp GROUP BY tmp.geo_accession HAVING COUNT(*) = 2").and_return([a3, a4])
        Annotation.geo_items(["1000|MA:0001", "1150|RS:1234"], 1).should == [0, [a3, a4], ["GSM3", "GSM4"]]
      end
    end
  end

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
    end

    describe "with no parameters" do
      it "should return the annotation hash, anatomy terms and rat strain terms" do
        OntologyTerm.should_receive(:cloud_term_ids).with(:ontology_ncbo_id => "1000").and_return(@anatomy_terms)
        OntologyTerm.should_receive(:cloud_term_ids).with(:ontology_ncbo_id => "1150").and_return(@rat_strain_terms)
        @annotations = []
        Annotation.build_cloud(nil, 1).should == [0, @annotations, @anatomy_terms, @rat_strain_terms]
      end
    end

    describe "with parameters" do
      it "should return the filtered annotation hash, anatomy terms and rat strain terms" do
        Annotation.should_receive(:geo_items).with(["rs1_id"], 1).and_return([5, [@a1, @a2], ["GSM1", "GSM2"]])
        OntologyTerm.should_receive(:cloud_term_ids).with(:ontology_ncbo_id => "1000", :geo_term_array => ["GSM1", "GSM2"]).and_return(@anatomy_terms)
        OntologyTerm.should_receive(:cloud_term_ids).with(:ontology_ncbo_id => "1150", :geo_term_array => ["GSM1", "GSM2"]).and_return(@rat_strain_terms)
        Annotation.build_cloud(["rs1_id"], 1).should == [5, @annotations, @anatomy_terms, [@rs2]]
      end
    end
  end

  describe "count by ontology array" do
    it "should return an array of ontologies and the number of annotations for each" do
      Annotation.stub!(:count).and_return(1)
      Annotation.count_by_ontology_array.should == [{:amount=>1, :name=>"Cell type"}, {:amount=>1, :name=>"Basic Vertebrate Anatomy"}, {:amount=>1, :name=>"Mammalian Phenotype"}, {:amount=>1, :name=>"Mouse adult gross anatomy"}, {:amount=>1, :name=>"Pathway Ontology"}, {:amount=>1, :name=>"Rat Strain Ontology"}, {:amount=>1, :name=>"Gene Ontology"}, {:amount=>1, :name=>"Medical Subject Headings"}, {:amount=>1, :name=>"NCI Thesaurus"}, {:amount=>1, :name=>"All ontology"}]
    end
  end

  describe "page" do
    it "should call paginate" do
      Annotation.should_receive(:paginate).with({:per_page=>20, :include=>[:ontology_term, :ontology], :order=>"ontology_terms.name, annotations.geo_accession", :conditions=>"conditions", :page=>2}).and_return(true)
      Annotation.page("conditions", 2, 20)
    end
  end

  describe "set_status" do
    describe "with verified" do
      describe "with unaudited" do
        it "should unverify it" do
          annotation = Factory.build(:annotation, :verified => true, :status => 'unaudited')
          annotation.should_receive(:save).and_return(true)
          annotation.set_status(1)
          annotation.status.should == "audited"
          annotation.verified.should == false
        end
      end
      describe "with audited" do
        it "should verify it" do
          annotation = Factory.build(:annotation, :verified => true, :status => 'audited')
          annotation.should_receive(:save).and_return(true)
          annotation.set_status(1)
          annotation.status.should == "audited"
          annotation.verified.should == false
        end
      end
    end

    describe "with unverified" do
      describe "with unaudited" do
        it "should unverify it" do
          annotation = Factory.build(:annotation, :verified => false, :status => 'unaudited')
          annotation.should_receive(:save).and_return(true)
          annotation.set_status(1)
          annotation.status.should == "audited"
          annotation.verified.should == true
        end
      end

      describe "with audited" do
        it "should verify it" do
          annotation = Factory.build(:annotation, :verified => false, :status => 'audited')
          annotation.should_receive(:save).and_return(true)
          annotation.set_status(1)
          annotation.status.should == "audited"
          annotation.verified.should == true
        end
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
        a = Factory.build(:annotation, :from => hash[:from], :to => hash[:to] )
        a.stub!(:field_value).and_return(hash[:full])
        a.in_context.should == hash[:context]
      end
    end
  end

  describe "full_text_highlighted" do
    data = { "amygdala" => {:full => "brain, amygdala", :full_highlighted => "brain, <strong class='highlight'>amygdala</strong>", :from => 8, :to => 15},
             "articular cartilage" => {:full => "Knee articular cartilage, 4 weeks following sham surgery", :full_highlighted => "Knee <strong class='highlight'>articular cartilage</strong>, 4 weeks following sham surgery", :from => 6, :to => 24},
             "pancreatic lymph node" => {:full => "BB Rat day 65 female diabetic prone mast cells from pancreatic lymph node", :full_highlighted => "BB Rat day 65 female diabetic prone mast cells from <strong class='highlight'>pancreatic lymph node</strong>", :from => 53, :to => 73},
             "cheese" => {:full => "this is something in the middle of cheese and this is the long text at the end", :full_highlighted => "this is something in the middle of <strong class='highlight'>cheese</strong> and this is the long text at the end", :from => 36, :to => 41},
             "special" => {:full => "special something in the middle of ending", :full_highlighted => "<strong class='highlight'>special</strong> something in the middle of ending", :from => 1, :to => 7},
           }

    data.keys.each do |key|
      it "should return the full text of the annotation highlighted for #{key}" do
        hash = data[key]
        a = Factory.build(:annotation, :from => hash[:from], :to => hash[:to] )
        a.stub!(:field_value).and_return(hash[:full])
        a.full_text_highlighted.should == hash[:full_highlighted]
      end
    end
  end


  describe "field_value" do
    it "should return the value of a field for the loaded item" do
      sample = Factory.build(:sample, :geo_accession => "GSM1234")
      annotation = Factory.build(:annotation, :field_name => "title", :geo_accession => "GSM1234")
      Annotation.should_receive(:load_item).with("GSM1234").and_return(sample)
      sample.should_receive(:send).with("title").and_return("field_value")
      annotation.field_value.should == "field_value"
    end
  end


end