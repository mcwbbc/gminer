class NCBOService
  include HTTParty
    base_uri 'ncbolabs-dev2.stanford.edu:8080'
    format :xml

  class << self
    def get_data(text, ncbo_ontology_id)
      retried = false
      parameters = {
        "longestOnly" => "false",
        "wholeWordOnly" => "true",
        "stopWords" => Constants::STOPWORDS,
        "scored" => "true",
        "localOntologyIDs" => "#{ncbo_ontology_id}",
        "levelMin" => "1",
        "levelMax" => "10",
        "text"  => "#{text}",
        "format" => "asXML"
      }
      begin
        NCBOService.post("/OBS_v1/oba/", :query => parameters)
      rescue EOFError, Errno::ECONNRESET
        raise NCBOException.new('too many connection resets', parameters) if retried
        retried = true
        retry
      end
    end

    def result_hash(text, ncbo_ontology_id)
      result = NCBOService.get_data(text, ncbo_ontology_id)
      hash = {"MGREP" => {}, "ISA_CLOSURE" => {}}
      annotations = result["obs.common.beans.ObaResultBean"]["annotations"]
      if annotations && annotations.any?
        bean = annotations["obs.common.beans.AnnotationBean"]
        annotation_array = bean.is_a?(Hash) ? [bean] : bean
        hash = annotation_array.inject({"MGREP" => {}, "ISA_CLOSURE" => {}}) do |h,annotation|
          concept = annotation["concept"]
          context = annotation["context"]
          if context["contextName"] == "MGREP"
            h["MGREP"][concept["localConceptID"].gsub("/","|")] = {:name => concept["preferredName"], :from => context["from"], :to => context["to"]}
          else
            if h["ISA_CLOSURE"][context["childConceptID"].gsub("/","|")].is_a?(Array)
              h["ISA_CLOSURE"][context["childConceptID"].gsub("/","|")] << {:name => concept["preferredName"], :id => concept["localConceptID"].gsub("/","|")}
            else
              h["ISA_CLOSURE"][context["childConceptID"].gsub("/","|")] = [{:name => concept["preferredName"], :id => concept["localConceptID"].gsub("/","|")}]
            end
          end
          h
        end
      end
      hash
    end
  end
end
