require 'spec_helper'

describe NCBOAnnotatorService do

  describe "current_ncbo_id" do
    it "should return an array of id, name, version" do
      NCBOAnnotatorService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return(ONTOLOGY_ID_HASH)
      NCBOAnnotatorService.current_ncbo_id(1000).should == ["39778", "Mouse adult gross anatomy", "1.194"]
    end

    it "should raise an exception on failure" do
      NCBOAnnotatorService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return({})
      lambda {NCBOAnnotatorService.current_ncbo_id(1000)}.should raise_error(NCBOException)
    end
  end

  describe "generate hash" do
    it "should return empty hashes for no results" do
      results = {"MGREP" => {}, "MAPPING"=>{}, "ISA_CLOSURE"=>{}}
      NCBOAnnotatorService.generate_hash([]).should == results
    end

    it "should clean up the returned hash from ncbo if there is one annotation" do
      hash = {'success' =>
              {'data' =>
                {"annotatorResultBean" =>
                  {"text" => "rat strain", "annotations" =>
                    {"annotationBean"=> [
                      {"concept" =>
                        {"preferredName"=>"rat strain", "localConceptId"=>"39234/RS:0000457", "synonyms"=>nil, "isTopLevel"=>"true", "localSemanticTypeIds" =>
                          {"string"=>"T999"},
                         "localOntologyId"=>"39234"},
                       "context" =>
                          {"termId"=>"6991983", "class"=>"obs.common.beans.MgrepContextBean", "termName"=>"rat strain", "from"=>"1", "contextName"=>"MGREP", "to"=>"10", "isDirect"=>"true"},
                       "score"=>"10.0"},
                       {"concept" =>
                         {"preferredName"=>"adrenal gland medulla", "localConceptId"=>"39778|MA:0000119", "synonyms"=>nil, "isTopLevel"=>"true", "localSemanticTypeIds" =>
                           {"string"=>"T999"},
                          "localOntologyId"=>"39778"},
                          "context"=>
                           {"mappingType"=>"Automatic", "class"=>"mappingContextBean", "contextName"=>"MAPPING", "mappedConceptId"=>"39478/Adrenal_Medulla", "isDirect"=>"false", 'from' => '10', 'to' => '30'},
                        "score"=>"14"}
                        ]
                      }}}}}

                results = {"MGREP"=>{"39234|RS:0000457"=>{:local_ontology_id=>"39234", :to=>"10", :from=>"1", :name=>"rat strain"}},
                "MAPPING"=>{"39778|MA:0000119"=>{:local_ontology_id=>"39778", :to=>"30", :from=>"10", :name=>"adrenal gland medulla"}},
                "ISA_CLOSURE"=>{}}

      NCBOAnnotatorService.generate_hash(hash['success']['data']['annotatorResultBean']['annotations']).should == results
    end

    it "should clean up the returned hash from ncbo if there are multiple annotations" do
      NCBOAnnotatorService.generate_hash(BIGHASH['success']['data']['annotatorResultBean']['annotations']).should == {"MGREP"=>{"MSH|C0007968"=>{:local_ontology_id=>"MSH", :to=>"6", :from=>"1", :name=>"Cheese"}}, "MAPPING"=>{}, "ISA_CLOSURE"=>{"MSH|C0007968"=>[{:local_ontology_id=>"MSH", :name=>"Dairy Products", :id=>"MSH|C0010947"}, {:local_ontology_id=>"MSH", :name=>"Food", :id=>"MSH|C0016452"}, {:local_ontology_id=>"MSH", :name=>"Technology, Industry, Agriculture (MeSH Category)", :id=>"MSH|C1256750"}, {:local_ontology_id=>"MSH", :name=>"Food and Beverages", :id=>"MSH|C0524819"}, {:local_ontology_id=>"MSH", :name=>"Index Medicus Descriptor", :id=>"MSH|C1256741"}, {:local_ontology_id=>"MSH", :name=>"MeSH Descriptors", :id=>"MSH|C1256739"}]}}
    end
  end

  describe "result_hash" do
    describe "failures" do
      it "should raise an exception without result" do
        NCBOAnnotatorService.should_receive(:get_data).with("word", "stopword", '1150', 'email', "id").and_return(nil)
        lambda {NCBOAnnotatorService.result_hash("word", "stopword", '1150', "id", 'email')}.should raise_error(NCBOException)
      end

      it "should raise an exception without result" do
        hash = {'errorStatus' => {'shortMessage' => 'short', 'longMessage' => 'long'}}
        NCBOAnnotatorService.should_receive(:get_data).with("word", "stopword", '1150', 'email', "id").and_return(hash)
        lambda {NCBOAnnotatorService.result_hash("word", "stopword", '1150', "id", 'email')}.should raise_error(NCBOException)
      end

      it "should raise an exception with success or errorStatus" do
        hash = {'something' => {}}
        NCBOAnnotatorService.should_receive(:get_data).with("word", "stopword", '1150', 'email', "id").and_return(hash)
        lambda {NCBOAnnotatorService.result_hash("word", "stopword", '1150', "id", 'email')}.should raise_error(NCBOException)
      end
    end

    describe "success" do
      describe "with annotations" do
        it "should return the generate hash results and ontology hash" do
          param_hash = {'success' => {'data' => {"annotatorResultBean"=>{"text"=>"rat strain", "annotations"=> ["annotations"], "ontologies" => {'ontologyUsedBean' => "mouse anatomy"}}}}}

          ontology_hash = {"42571"=>"1000"}
          result_hash = {"MGREP"=>{"42571|MA:0000415"=>{:to=>"4", :from=>"1", :local_ontology_id=>"42571", :name=>"lung"}},
                      "MAPPING"=>{"42571|MA:0000415"=>{:to=>"4", :from=>"1", :local_ontology_id=>"42571", :name=>"lung"}},
                      "ISA_CLOSURE"=>{"42571|MA:0000415"=>[{:local_ontology_id=>"42571", :name=>"thoracic cavity organ", :id=>"42571|MA:0000557"}, {:local_ontology_id=>"42571", :name=>"thoracic segment organ", :id=>"42571|MA:0000563"}, {:local_ontology_id=>"42571", :name=>"trunk organ", :id=>"42571|MA:0000516"}]}}

          results = [result_hash, ontology_hash]

          NCBOAnnotatorService.should_receive(:generate_ontology_hash).with("mouse anatomy").and_return(ontology_hash)
          NCBOAnnotatorService.should_receive(:get_data).with("word", "stopword", '1150', 'email', "id").and_return(param_hash)
          NCBOAnnotatorService.should_receive(:generate_hash).with(["annotations"]).and_return(result_hash)
          NCBOAnnotatorService.result_hash("word", "stopword", '1150', "id", 'email').should == results
        end
      end

      describe "without annotations" do
        it "should return the generate hash results and an empty hash" do
          hash = {'success' => {'data' => {"annotatorResultBean"=>{"text"=>"rat strain", "annotations"=> []}}}}
          results = [{"MGREP" => {}, "ISA_CLOSURE" => {}, "MAPPING" => {}}, {}]
          NCBOAnnotatorService.should_receive(:get_data).with("word", "stopword", '1150', 'email', "id").and_return(hash)
          NCBOAnnotatorService.should_receive(:generate_hash).with([]).and_return({"MGREP" => {}, "ISA_CLOSURE" => {}, "MAPPING" => {}})
          NCBOAnnotatorService.result_hash("word", "stopword", '1150', "id", 'email').should == results
        end
      end
    end
  end

  describe "get data" do
    before(:each) do
      @default_params = {'email' => 'user@comp.com',
                         "longestOnly"=>"false",
                         "wholeWordOnly"=>"true",
                         "stopWords"=>"stopwords",
                         "minTermSize"=>"2",
                         "withSynonyms"=>"true",
                         "scored"=>"true",
                         "ontologiesToExpand" => "1150",
                         "ontologiesToKeepInResult" => "1234",
                         "isVirtualOntologyId"=>"true",
                         "levelMax"=>"10",
                         "textToAnnotate"=>"word",
                         "format"=>"xml"} #,"ontologiesToExpand" => "1234"}
    end

    it "should get the xml from ncbo, which is parsed into a hash by httparty" do
      NCBOAnnotatorService.should_receive(:post).with("/obs/annotator", {:body => @default_params}).and_return({:key => "value"})
      NCBOAnnotatorService.get_data("word", "stopwords", '1150', 'user@comp.com', "1234").should == {:key => "value"}
    end

    it "should retry on Errno::ECONNRESET" do
      query = {:body=>@default_params}
      NCBOAnnotatorService.should_receive(:post).with("/obs/annotator", query).once.and_raise(Errno::ECONNRESET)
      NCBOAnnotatorService.should_receive(:post).with("/obs/annotator", query).and_return({:key => "value"})
      NCBOAnnotatorService.get_data("word", "stopwords", '1150', 'user@comp.com', "1234").should == {:key => "value"}
    end

    it "should fail with too many resets" do
      NCBOAnnotatorService.should_receive(:post).with("/obs/annotator", {:body=>@default_params}).twice.and_raise(Errno::ECONNRESET)
      lambda {NCBOAnnotatorService.get_data("word", "stopwords", '1150', 'user@comp.com', "1234")}.should raise_error(NCBOException)
    end

    it "should raise an exception on failure" do
      NCBOAnnotatorService.should_receive(:post).with("/obs/annotator", {:body=>@default_params}).twice.and_raise(Exception)
      lambda {NCBOAnnotatorService.get_data("word", "stopwords", '1150', 'user@comp.com', "1234")}.should raise_error(NCBOException)
    end
  end

end

ONTOLOGY_ID_HASH = {"success"=>
  {"data"=>
    {"ontologyBean"=>
      {"contactName"=>"Anatomy JAX",
       "isFoundry"=>"1",
       "hasViews"=>nil,
       "format"=>"OBO",
       "filenames"=>{"string"=>"adult_mouse_anatomy.obo"},
       "dateReleased"=>"2009-04-12 02:32:33.0 PDT",
       "viewOnOntologyVersionId"=>nil,
       "versionStatus"=>"production",
       "groupIds"=>{"int"=>"6001"},
       "filePath"=>"/1000/9",
       "codingScheme"=>
        "http://www.bioontology.org/39778/Mouse adult gross anatomy|1000/9",
       "categoryIds"=>{"int"=>["2812", "2811", "2810", "2817"]},
       "id"=>"39778",
       "versionNumber"=>"1.194",
       "isRemote"=>"0",
       "abbreviation"=>"MA",
       "userId"=>"38116",
       "statusId"=>"3",
       "isView"=>"false",
       "isManual"=>"0",
       "homepage"=>"http://www.informatics.jax.org/searches/AMA_form.shtml",
       "internalVersionNumber"=>"9",
       "dateCreated"=>"2009-04-12 02:32:33.0 PDT",
       "oboFoundryId"=>"adult_mouse_anatomy",
       "description"=>
        "A structured controlled vocabulary of the adult anatomy of the mouse (Mus).",
       "contactEmail"=>"anatomy@informatics.jax.org",
       "displayLabel"=>"Mouse adult gross anatomy",
       "ontologyId"=>"1000",
       "virtualViewIds"=>nil}},
   "accessDate"=>"2009-10-02 12:49:41.718 PDT",
   "accessedResource"=>"/bioportal/virtual/ontology/1000"}}

BIGHASH = {'success' => {"data"=>
  {"annotatorResultBean"=>
    {"text"=>"cheese",
     "annotations"=>
      {"annotationBean"=>
        [{"concept"=>
           {"preferredName"=>"Cheese",
            "localConceptId"=>"MSH/C0007968",
            "synonyms"=>{"string"=>"Cheeses"},
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"Food",
                 "conceptId"=>"MSH/C0007968",
                 "localSemanticTypeId"=>"T168"},
                {"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C0007968",
                 "localSemanticTypeId"=>"T000"}]}},
          "context"=>
           {"class"=>"mgrepContextBean",
            "term"=>
             {"name"=>"Cheese",
              "isPreferred"=>"1",
              "localConceptId"=>"MSH/C0007968",
              "dictionaryId"=>"1"},
            "from"=>"1",
            "contextName"=>"MGREP",
            "to"=>"6",
            "isDirect"=>"true"},
          "score"=>"10"},
         {"concept"=>
           {"preferredName"=>"Dairy Products",
            "localConceptId"=>"MSH/C0010947",
            "synonyms"=>
             {"string"=>
               ["Dairy Product", "Products, Dairy", "Product, Dairy"]},
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"Food",
                 "conceptId"=>"MSH/C0010947",
                 "localSemanticTypeId"=>"T168"},
                {"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C0010947",
                 "localSemanticTypeId"=>"T000"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"1",
            "isDirect"=>"false"},
          "score"=>"8"},
         {"concept"=>
           {"preferredName"=>"Food",
            "localConceptId"=>"MSH/C0016452",
            "synonyms"=>{"string"=>"Foods"},
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C0016452",
                 "localSemanticTypeId"=>"T000"},
                {"name"=>"Food",
                 "conceptId"=>"MSH/C0016452",
                 "localSemanticTypeId"=>"T168"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"2",
            "isDirect"=>"false"},
          "score"=>"7"},
         {"concept"=>
           {"preferredName"=>
             "Technology, Industry, Agriculture (MeSH Category)",
            "localConceptId"=>"MSH/C1256750",
            "synonyms"=>nil,
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"Classification",
                 "conceptId"=>"MSH/C1256750",
                 "localSemanticTypeId"=>"T185"},
                {"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C1256750",
                 "localSemanticTypeId"=>"T000"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"4",
            "isDirect"=>"false"},
          "score"=>"6"},
         {"concept"=>
           {"preferredName"=>"Food and Beverages",
            "localConceptId"=>"MSH/C0524819",
            "synonyms"=>{"string"=>"Beverages and Food"},
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"Food",
                 "conceptId"=>"MSH/C0524819",
                 "localSemanticTypeId"=>"T168"},
                {"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C0524819",
                 "localSemanticTypeId"=>"T000"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"3",
            "isDirect"=>"false"},
          "score"=>"6"},
         {"concept"=>
           {"preferredName"=>"Index Medicus Descriptor",
            "localConceptId"=>"MSH/C1256741",
            "synonyms"=>{"string"=>"MeSH Descriptors Class 1"},
            "isTopLevel"=>"0",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"Intellectual Product",
                 "conceptId"=>"MSH/C1256741",
                 "localSemanticTypeId"=>"T170"},
                {"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C1256741",
                 "localSemanticTypeId"=>"T000"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"5",
            "isDirect"=>"false"},
          "score"=>"5"},
         {"concept"=>
           {"preferredName"=>"MeSH Descriptors",
            "localConceptId"=>"MSH/C1256739",
            "synonyms"=>nil,
            "isTopLevel"=>"1",
            "localOntologyId"=>"MSH",
            "semanticTypes"=>
             {"semanticTypeBean"=>
               [{"name"=>"UMLS concept",
                 "conceptId"=>"MSH/C1256739",
                 "localSemanticTypeId"=>"T000"},
                {"name"=>"Intellectual Product",
                 "conceptId"=>"MSH/C1256739",
                 "localSemanticTypeId"=>"T170"}]}},
          "context"=>
           {"concept"=>
             {"preferredName"=>"Cheese",
              "localConceptId"=>"MSH/C0007968",
              "synonyms"=>{"string"=>"Cheeses"},
              "isTopLevel"=>"0",
              "localOntologyId"=>"MSH",
              "semanticTypes"=>
               {"semanticTypeBean"=>
                 [{"name"=>"Food",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T168"},
                  {"name"=>"UMLS concept",
                   "conceptId"=>"MSH/C0007968",
                   "localSemanticTypeId"=>"T000"}]}},
            "class"=>"isaContextBean",
            "contextName"=>"ISA_CLOSURE",
            "level"=>"6",
            "isDirect"=>"false"},
          "score"=>"5"}]},
     "resultId"=>"OBA_RESULT_edaa"}},
 "accessDate"=>"2009-08-10 08:00:23.939 PDT",
 "accessedResource"=>"/obs/annotator"}}
