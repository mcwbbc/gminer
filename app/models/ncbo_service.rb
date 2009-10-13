class NCBOService
  include HTTParty
    base_uri 'rest.bioontology.org'
    format :xml

  class << self

    def current_ncbo_id(ncbo_id)
      begin
        result = NCBOService.get("/bioportal/virtual/ontology/#{ncbo_id}")
        bean = result['success']['data']['ontologyBean']
        name = bean['displayLabel']
        version = bean['versionNumber']
        id = bean['id']
        [id, name, version]
      rescue Exception => e
        puts "#{e.inspect} -- #{e.message}"
        raise NCBOException.new('ontology update error', ncbo_id)
      end
    end

    def get_data(text, ncbo_ontology_id, stopwords)
      retried = false
      parameters = {
        "longestOnly" => "false",
        "wholeWordOnly" => "true",
        "stopWords" => stopwords,
        "scored" => "true",
        "ontologiesToExpand" => "#{ncbo_ontology_id}",
        "ontologiesToKeepInResult" => "#{ncbo_ontology_id}",
        "levelMax" => "10",
        "textToAnnotate"  => "#{text}",
        "format" => "xml"
      }
      begin
        data = NCBOService.post("/obs_hibernate/annotator", :body => parameters)
      rescue EOFError, Errno::ECONNRESET
        raise NCBOException.new('too many connection resets', parameters) if retried
        retried = true
        retry
      rescue Exception => e
        puts "#{e.inspect} -- #{e.message}"
        raise NCBOException.new('invalid XML error', parameters) if retried
        retried = true
        retry
      end
    end

    def result_hash(text, ncbo_ontology_id, stopwords)
      begin
        result = NCBOService.get_data(text, ncbo_ontology_id, stopwords)
        sleep(1) if !result['success']
      end until result['success']
      hash = {"MGREP" => {}, "ISA_CLOSURE" => {}}
      annotations = result['success']['data']['annotatorResultBean']['annotations']
      if annotations && annotations.any?
        bean = annotations["annotationBean"]
        annotation_array = bean.is_a?(Hash) ? [bean] : bean
        hash = annotation_array.inject({"MGREP" => {}, "ISA_CLOSURE" => {}}) do |h, annotation|
          concept = annotation["concept"]
          context = annotation["context"]
          if context["contextName"] == "MGREP"
            h["MGREP"][concept["localConceptId"].gsub("/","|")] = {:name => concept["preferredName"], :from => context["from"], :to => context["to"]}
          elsif context["contextName"] == "MAPPING"
            # do nothing with the mappings for now
          else
            if h["ISA_CLOSURE"][context['concept']["localConceptId"].gsub("/","|")].is_a?(Array)
              h["ISA_CLOSURE"][context['concept']["localConceptId"].gsub("/","|")] << {:name => concept["preferredName"], :id => concept["localConceptId"].gsub("/","|")}
            else
              h["ISA_CLOSURE"][context['concept']["localConceptId"].gsub("/","|")] = [{:name => concept["preferredName"], :id => concept["localConceptId"].gsub("/","|")}]
            end
          end
          h
        end
      end
      hash
    end
  end
end
