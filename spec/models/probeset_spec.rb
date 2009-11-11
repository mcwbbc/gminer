require 'spec_helper'

describe Probeset do

  describe "generate_platform_hash" do
    it "should return a hash of platforms based on the supplied probesets" do
      p = Probeset.spawn
      p1 = Platform.spawn
      Platform.should_receive(:for_probeset).with(p.name).and_return([p1])
      Probeset.generate_platform_hash([p]).should == {p.id => [p1]}
    end
  end

  describe "page" do
    it "should call paginate" do
      Probeset.should_receive(:paginate).with({:conditions=>"conditions", :order=>"name", :page=>2, :per_page=>20}).and_return(true)
      Probeset.page("conditions", 2, 20)
    end
  end

  describe "to_param" do
    {"1234_at" => "1234_at", "AFFX-18SRNAMur/X00686_3_at" => "AFFX-18SRNAMur%5CX00686_3_at", "name space" => "name+space"}.each do |name, encoded|
      it "should return the url encoded name as the param for #{name}" do
        p = Probeset.spawn(:name => name)
        p.to_param.should == encoded
      end
    end
  end

  describe "ontology_term_hash" do
    it "should return a hash with terms and counts" do
      p = Probeset.spawn
      ot = OntologyTerm.spawn(:annotations_count => 5)
      ot.should_receive(:found_count).and_return(5)
      OntologyTerm.should_receive(:find).with(:all, :select => "ontology_terms.*, count(ontology_terms.id) AS found_count", :joins => "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id INNER JOIN samples ON annotations.geo_accession = samples.geo_accession INNER JOIN detections ON detections.sample_id = samples.id INNER JOIN probesets ON detections.probeset_id = probesets.id AND probesets.id = #{p.id} AND detections.abs_call = 'P' AND annotations.ncbo_id = '1000' AND annotations.verified = 1", :group  => "ontology_terms.id", :order  => "ontology_terms.name").and_return([ot])
      OntologyTerm.should_receive(:count_for_probeset).with(ot.id, p.id, '1000').and_return(5)
      p.ontology_term_hash('1000', 'P').should == {ot.term_id => {:term => ot, :found_count => 5, :total_count => 5}}
    end
  end

  describe "generate_gooogle_chart" do
    it "should call the Graph and generate" do
      p = Probeset.spawn
      graph = Graph.new([])
      Graph.should_receive(:new).with(["array"]).and_return(graph)
      graph.should_receive(:generate).and_return("image")
      p.generate_gooogle_chart(["array"]).should == "image"
    end
  end

  describe "generate_term_array" do
    before(:each) do
      @p = Probeset.spawn
      @term1 = OntologyTerm.spawn
      @term2 = OntologyTerm.spawn
      @term3 = OntologyTerm.spawn
    end

    it "should return a hash with the terms, counts, and totals seperated" do
      p_hash = {@term1.term_id => {:total_count => 1, :found_count => 1, :term => @term1}}
      a_hash = {@term2.term_id => {:total_count => 2, :found_count => 2, :term => @term2}}
      m_hash = {@term3.term_id => {:total_count => 3, :found_count => 3, :term => @term3}}

      @p.should_receive(:ontology_term_hash).with("1000", 'P').and_return(p_hash)
      @p.should_receive(:ontology_term_hash).with("1000", 'A').and_return(a_hash)
      @p.should_receive(:ontology_term_hash).with("1000", 'M').and_return(m_hash)

      @p.generate_term_array.should == [
                                        {:total_count=>1, :absent_count=>0, :marginal_count=>0, :present_count=>1, :term=> @term1},
                                        {:total_count=>2, :absent_count=>2, :marginal_count=>0, :present_count=>0, :term => @term2},
                                        {:total_count=>3, :absent_count=>0, :marginal_count=>3, :present_count=>0, :term=>@term3},
                                      ]
    end


    it "should return a hash with the terms, counts, and totals combined" do
      p_hash = {@term1.term_id => {:total_count => 4, :found_count => 1, :term => @term1}}
      a_hash = {@term2.term_id => {:total_count => 2, :found_count => 2, :term => @term2}, @term1.term_id => {:total_count => 4, :found_count => 2, :term => @term1}}
      m_hash = {@term3.term_id => {:total_count => 3, :found_count => 3, :term => @term3}, @term1.term_id => {:total_count => 4, :found_count => 1, :term => @term1}}

      @p.should_receive(:ontology_term_hash).with("1000", 'P').and_return(p_hash)
      @p.should_receive(:ontology_term_hash).with("1000", 'A').and_return(a_hash)
      @p.should_receive(:ontology_term_hash).with("1000", 'M').and_return(m_hash)

      @p.generate_term_array.should == [
                                        {:total_count=>2, :absent_count=>2, :marginal_count=>0, :present_count=>0, :term => @term2},
                                        {:total_count=>3, :absent_count=>0, :marginal_count=>3, :present_count=>0, :term => @term3},
                                        {:total_count=>4, :absent_count=>2, :marginal_count=>1, :present_count=>1, :term => @term1},
                                      ]
    end

  end

end
