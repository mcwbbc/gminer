require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NCBOService do

  describe "current_ncbo_id" do
    it "should return an array of id, name, version" do
      NCBOService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return(ONTOLOGY_ID_HASH)
      NCBOService.current_ncbo_id(1000).should == ["39778", "Mouse adult gross anatomy", "1.194"]
    end

    it "should raise an exception on failure" do
      NCBOService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return({})
      lambda {NCBOService.current_ncbo_id(1000)}.should raise_error(NCBOException)
    end
  end

  describe "result hash" do
    it "should return empty hashes for no results" do
      hash = {'success' => {'data' => {"annotatorResultBean"=>{"text"=>"rat strain", "annotations"=> []}}}}
      NCBOService.should_receive(:get_data).with("word", "id", "stopword").and_return(hash)
      NCBOService.result_hash("word", "id", "stopword").should == {
        "MGREP" => {},
        "ISA_CLOSURE"=>{}
      }
    end

    it "should clean up the returned hash from ncbo if there is one annotation" do
      hash = {'success' => 
              {'data' => 
                {"annotatorResultBean" => 
                  {"text" => "rat strain", "annotations" => 
                    {"annotationBean"=> 
                      {"concept" => 
                        {"preferredName"=>"rat strain", "localConceptId"=>"39234/RS:0000457", "synonyms"=>nil, "isTopLevel"=>"true", "localSemanticTypeIds" => 
                          {"string"=>"T999"},
                         "localOntologyId"=>"39234"},
                       "context" =>
                          {"termId"=>"6991983", "class"=>"obs.common.beans.MgrepContextBean", "termName"=>"rat strain", "from"=>"1", "contextName"=>"MGREP", "to"=>"10", "isDirect"=>"true"},
                       "score"=>"10.0"}}}}}}

      NCBOService.should_receive(:get_data).with("word", "id", "stopwords").and_return(hash)
      NCBOService.result_hash("word", "id", "stopwords").should == {
        "MGREP" => {
          "39234|RS:0000457"=>{:name=>"rat strain", :from => "1", :to => "10"}
        },
        "ISA_CLOSURE"=>{}
      }
    end

    it "should clean up the returned hash from ncbo if there are multiple annotations" do
      NCBOService.should_receive(:get_data).with("cheese", "MSH", "stopwords").and_return(BIGHASH)
      NCBOService.result_hash("cheese", "MSH", "stopwords").should == {"MGREP"=>{"MSH|C0007968"=>{:to=>"6", :from=>"1", :name=>"Cheese"}}, "ISA_CLOSURE"=>{"MSH|C0007968"=>[{:name=>"Dairy Products", :id=>"MSH|C0010947"}, {:name=>"Food", :id=>"MSH|C0016452"}, {:name=>"Technology, Industry, Agriculture (MeSH Category)", :id=>"MSH|C1256750"}, {:name=>"Food and Beverages", :id=>"MSH|C0524819"}, {:name=>"Index Medicus Descriptor", :id=>"MSH|C1256741"}, {:name=>"MeSH Descriptors", :id=>"MSH|C1256739"}]}}
    end
  end

  describe "get data" do
    it "should get the xml from ncbo, which is parsed into a hash by httparty" do
      NCBOService.should_receive(:post).with("/obs_hibernate/annotator", {:body=>{"levelMax"=>"10", "stopWords"=>"stopwords", "format"=>"xml", "longestOnly"=>"false", "textToAnnotate"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "ontologiesToExpand"=>"id", "ontologiesToKeepInResult"=>"id"}}).and_return({:key => "value"})
      NCBOService.get_data("word", "id", "stopwords").should == {:key => "value"}
    end

    it "should retry on Errno::ECONNRESET" do
      query = {:body=>{"levelMax"=>"10", "stopWords"=>"stopwords", "format"=>"xml", "longestOnly"=>"false", "textToAnnotate"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "ontologiesToExpand"=>"id", "ontologiesToKeepInResult"=>"id"}}
      NCBOService.should_receive(:post).with("/obs_hibernate/annotator", query).once.and_raise(Errno::ECONNRESET)
      NCBOService.should_receive(:post).with("/obs_hibernate/annotator", query).and_return({:key => "value"})
      NCBOService.get_data("word", "id", "stopwords").should == {:key => "value"}
    end

    it "should fail with too many resets" do
      NCBOService.should_receive(:post).with("/obs_hibernate/annotator", {:body=>{"levelMax"=>"10", "stopWords"=>"stopwords", "format"=>"xml", "longestOnly"=>"false", "textToAnnotate"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "ontologiesToKeepInResult"=>"id", "ontologiesToExpand"=>"id"}}).twice.and_raise(Errno::ECONNRESET)
      lambda {NCBOService.get_data("word", "id", "stopwords")}.should raise_error(NCBOException)
    end

    it "should raise an exception on failure" do
      NCBOService.should_receive(:post).with("/obs_hibernate/annotator", {:body=>{"levelMax"=>"10", "stopWords"=>"stopwords", "format"=>"xml", "longestOnly"=>"false", "textToAnnotate"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "ontologiesToKeepInResult"=>"id", "ontologiesToExpand"=>"id"}}).twice.and_raise(Exception)
      lambda {NCBOService.get_data("word", "id", "stopwords")}.should raise_error(NCBOException)
    end
  end

end

PROXY_ERROR = <<HTML
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>502 Proxy Error</title>
</head><body>
<h1>Proxy Error</h1>
<p>The proxy server received an invalid
response from an upstream server.<br />
The proxy server could not handle the request <em><a
href="/obs_hibernate/annotator">POST&nbsp;/obs_hibernate/annotator</a></em>.<p>
Reason: <strong>Error reading from remote
server</strong></p></p>
<hr>
<address>Apache/2.2.3 (Red Hat) Server at rest.bioontology.org Port
80</address>
</body></html>
HTML

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
 "accessedResource"=>"/obs_hibernate/annotator"}}
