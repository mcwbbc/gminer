require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NCBOService do

  describe "result hash" do
    it "should return empty hashes for no results" do
      hash = {"obs.common.beans.ObaResultBean"=>{"text"=>"rat strain", "annotations"=> []}}
      NCBOService.should_receive(:get_data).with("word", "id").and_return(hash)
      NCBOService.result_hash("word", "id").should == {
        "MGREP" => {},
        "ISA_CLOSURE"=>{}
      }
    end

    it "should clean up the returned hash from ncbo if there is one annotation" do
      hash = {"obs.common.beans.ObaResultBean"=>{"text"=>"rat strain", "annotations"=>{"obs.common.beans.AnnotationBean"=>{"concept"=>{"preferredName"=>"rat strain", "localConceptID"=>"39234/RS:0000457", "synonyms"=>nil, "isTopLevel"=>"true", "localSemanticTypeIDs"=>{"string"=>"T999"}, "localOntologyID"=>"39234"}, "context"=>{"termID"=>"6991983", "class"=>"obs.common.beans.MgrepContextBean", "termName"=>"rat strain", "from"=>"1", "contextName"=>"MGREP", "to"=>"10", "isDirect"=>"true"}, "score"=>"10.0"}}}}
      NCBOService.should_receive(:get_data).with("word", "id").and_return(hash)
      NCBOService.result_hash("word", "id").should == {
        "MGREP" => {
          "39234|RS:0000457"=>{:name=>"rat strain", :from => "1", :to => "10"}
        },
        "ISA_CLOSURE"=>{}
      }
    end

    it "should clean up the returned hash from ncbo if there are multiple annotations" do
      NCBOService.should_receive(:get_data).with("word", "id").and_return(BIGHASH)
      NCBOService.result_hash("word", "id").should == {
        "MGREP" => {
          "MSH|C0003062"=>{:name=>"Animals", :from => "19", :to => "25"},
          "MSH|C0034693"=>{:name=>"Rattus norvegicus", :from => "1", :to => "17"},
          "MSH|C0034721"=>{:name=>"Rattus", :from => "1", :to => "6"}
        },
        "ISA_CLOSURE" => {
          "MSH|C0003062"=> [
            {:name => "MeSH Descriptors", :id => "MSH|C1256739"}
            ],
          "MSH|C0034721"=> [
            {:name => "Animals", :id => "MSH|C0003062"},
            {:name => "Vertebrates", :id => "MSH|C0042567"},
            {:name => "MeSH Descriptors", :id => "MSH|C1256739"}
            ]
        }
      }
    end
  end

  describe "get data" do
    it "should get the xml from ncbo, which is parsed into a hash by httparty" do
      NCBOService.should_receive(:post).with("/OBS_v1/oba/", {:query=>{"levelMax"=>"10", "stopWords"=>"I,a,about,an,and,are,as,at,be,by,com,de,en,each,for,from,how,in,is,it,la,of,on,or,that,the,this,to,was,what,when,where,who,will,with,und,the,www,et,al.", "format"=>"asXML", "longestOnly"=>"false", "levelMin"=>"1", "text"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "localOntologyIDs"=>"id"}}).and_return({:key => "value"})
      NCBOService.get_data("word", "id").should == {:key => "value"}
    end

    it "should retry on Errno::ECONNRESET" do
      pending("need to get it to return exception first, then value")
      query = {:query=>{"levelMax"=>"10", "stopWords"=>"I,a,about,an,and,are,as,at,be,by,com,de,en,each,for,from,how,in,is,it,la,of,on,or,that,the,this,to,was,what,when,where,who,will,with,und,the,www,et,al.", "format"=>"asXML", "longestOnly"=>"false", "levelMin"=>"1", "text"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "localOntologyIDs"=>"id"}}
      NCBOService.should_receive(:post).with("/OBS_v1/oba/", query).once.and_raise(Errno::ECONNRESET)
      NCBOService.should_receive(:post).with("/OBS_v1/oba/", query).and_return({:key => "value"})
      NCBOService.get_data("word", "id").should == {:key => "value"}
    end

    it "should fail with too many resets" do
      NCBOService.should_receive(:post).with("/OBS_v1/oba/", {:query=>{"levelMax"=>"10", "stopWords"=>"I,a,about,an,and,are,as,at,be,by,com,de,en,each,for,from,how,in,is,it,la,of,on,or,that,the,this,to,was,what,when,where,who,will,with,und,the,www,et,al.", "format"=>"asXML", "longestOnly"=>"false", "levelMin"=>"1", "text"=>"word", "wholeWordOnly"=>"true", "scored"=>"true", "localOntologyIDs"=>"id"}}).twice.and_raise(Errno::ECONNRESET)
      lambda {NCBOService.get_data("word", "id")}.should raise_error(NCBOException)
    end

  end

end


BIGHASH = {"obs.common.beans.ObaResultBean"=>
  {"annotations"=>{"obs.common.beans.AnnotationBean"=>
  [{"concept"=>
     {"preferredName"=>"Animals",
      "localConceptID"=>"MSH/C0003062",
      "synonyms"=>{"string"=>["Animal", "Metazoa", "Animalia"]},
      "isTopLevel"=>"false",
      "localSemanticTypeIDs"=>{"string"=>["T008", "T000"]},
      "localOntologyID"=>"MSH"},
    "context"=>
     {"class"=>"obs.common.beans.IsaContextBean",
      "contextName"=>"ISA_CLOSURE",
      "level"=>"7",
      "childConceptID"=>"MSH/C0034721",
      "isDirect"=>"false"},
    "score"=>"13.0"},
   {"concept"=>
     {"preferredName"=>"Animals",
      "localConceptID"=>"MSH/C0003062",
      "synonyms"=>{"string"=>["Animal", "Metazoa", "Animalia"]},
      "isTopLevel"=>"false",
      "localSemanticTypeIDs"=>{"string"=>["T008", "T000"]},
      "localOntologyID"=>"MSH"},
    "context"=>
     {"termID"=>"158968",
      "class"=>"obs.common.beans.MgrepContextBean",
      "termName"=>"Animals",
      "from"=>"19",
      "contextName"=>"MGREP",
      "to"=>"25",
      "isDirect"=>"true"},
    "score"=>"13.0"},
    {"concept"=>
      {"preferredName"=>"Rattus norvegicus",
       "localConceptID"=>"MSH/C0034693",
       "synonyms"=>{"string"=>"Rats, Norway"},
       "isTopLevel"=>"false",
       "localSemanticTypeIDs"=>{"string"=>["T015", "T000"]},
       "localOntologyID"=>"MSH"},
     "context"=>
      {"termID"=>"622135",
       "class"=>"obs.common.beans.MgrepContextBean",
       "termName"=>"Rattus norvegicus",
       "from"=>"1",
       "contextName"=>"MGREP",
       "to"=>"17",
       "isDirect"=>"true"},
     "score"=>"10.0"},
    {"concept"=>
      {"preferredName"=>"Rattus",
       "localConceptID"=>"MSH/C0034721",
       "synonyms"=>{"string"=>["Rats", "Rat"]},
       "isTopLevel"=>"false",
       "localSemanticTypeIDs"=>{"string"=>["T015", "T000"]},
       "localOntologyID"=>"MSH"},
     "context"=>
      {"termID"=>"361726",
       "class"=>"obs.common.beans.MgrepContextBean",
       "termName"=>"Rattus",
       "from"=>"1",
       "contextName"=>"MGREP",
       "to"=>"6",
       "isDirect"=>"true"},
     "score"=>"10.0"},
     {"concept"=>
       {"preferredName"=>"Vertebrates",
        "localConceptID"=>"MSH/C0042567",
        "synonyms"=>{"string"=>"Vertebrate"},
        "isTopLevel"=>"false",
        "localSemanticTypeIDs"=>{"string"=>["T000", "T010"]},
        "localOntologyID"=>"MSH"},
      "context"=>
       {"class"=>"obs.common.beans.IsaContextBean",
        "contextName"=>"ISA_CLOSURE",
        "level"=>"5",
        "childConceptID"=>"MSH/C0034721",
        "isDirect"=>"false"},
      "score"=>"5.0"},
      {"concept"=>
        {"preferredName"=>"MeSH Descriptors",
         "localConceptID"=>"MSH/C1256739",
         "synonyms"=>nil,
         "isTopLevel"=>"true",
         "localSemanticTypeIDs"=>{"string"=>["T170", "T000"]},
         "localOntologyID"=>"MSH"},
       "context"=>
        {"class"=>"obs.common.beans.IsaContextBean",
         "contextName"=>"ISA_CLOSURE",
         "level"=>"3",
         "childConceptID"=>"MSH/C0003062",
         "isDirect"=>"false"},
       "score"=>"9.0"},
      {"concept"=>
        {"preferredName"=>"MeSH Descriptors",
         "localConceptID"=>"MSH/C1256739",
         "synonyms"=>nil,
         "isTopLevel"=>"true",
         "localSemanticTypeIDs"=>{"string"=>["T170", "T000"]},
         "localOntologyID"=>"MSH"},
       "context"=>
        {"class"=>"obs.common.beans.IsaContextBean",
         "contextName"=>"ISA_CLOSURE",
         "level"=>"10",
         "childConceptID"=>"MSH/C0034721",
         "isDirect"=>"false"},
       "score"=>"9.0"}]
}}}