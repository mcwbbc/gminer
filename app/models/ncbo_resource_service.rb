class NcboResourceService
#  http://rest.bioontology.org/resource_index/byconcept/virtual/1000/false/true/0/1?conceptid=MA:0000072
  include HTTParty
    base_uri 'rest.bioontology.org'
    format :xml
    headers ({'User-Agent' => 'gminer-public'})

  class << self

    def get_annotations(geo_accession)
      retried = false
      query = {:elementid => geo_accession, :apikey => "apikey", :applicationid => "gminer-public"}
      begin
#        http://rest.bioontology.org/resource_index/byelement/GEO/false/true/false/0/10000?elementid=GDS3224&apikey=YourAPIKey&applicationid=NCBOtest
        data = NcboResourceService.get("/resource_index/byelement/GEO/false/true/false/0/10000", :query => query, :timeout => 600)
      rescue EOFError, Errno::ECONNRESET
        Rails.logger.debug("Connection resets retry")
        raise NCBOException.new('too many connection resets', query) if retried
        retry
      rescue Timeout::Error
        Rails.logger.debug("Timeout error retry")
        raise NCBOException.new('consecutive timeout errors', query) if retried
        retry
      rescue Exception => e
        Rails.logger.debug("#{e.inspect} -- #{e.message}")
        raise NCBOException.new('invalid XML error', query) if retried
        retried = true
        retry
      end
    end

    def get_data(term_ids)
      retried = false
      parameters = {
        "email" => 'email@mcw.edu',
        "applicationid" => 'GMiner',
        "conceptids" => term_ids,
        "isVirtualOntologyId" => "true",
        "mode" => "INTERSECTION",
        "resourceids" => "", #default all, #GEO
        "elementDetails" => "false",
        "counts" => "true",
        "offset"  => "0",
        "limit"  => "0",
        "format" => "xml"
      }

      begin
        data = NcboResourceService.post("/resource_index/search", :body => parameters)
      rescue EOFError, Errno::ECONNRESET
        raise NCBOException.new('too many connection resets', parameters) if retried
        retried = true
        retry
      rescue Timeout::Error
        Rails.logger.debug("Timeout error retried: #{retried}")
        raise NCBOException.new('consecutive timeout errors', parameters) if retried
        retried = true
        retry
      rescue Exception => e
        Rails.logger.debug("#{e.inspect} -- #{e.message}")
        raise NCBOException.new('invalid XML error', parameters) if retried
        retried = true
        retry
      end
    end

    def resource_count_hash(term_ids)
      result = NcboResourceService.get_data(term_ids)
      if result && result['success']
        result_array = result['success']['data']['list']['result']
        result_array.inject({}) do |hash, member|
          if member['resultStatistics']['statistics']['annotationCount'].to_i > 0
            concept_ids = []
            term_id_array = term_ids.split(',')
            concept_id_array = member['localConceptIds']['string']
            concept_id_array.each do |id|
              local_ncbo, term_id = id.split('/')
              term_id_array.each do |t_id|
                virtual_id, term = t_id.split('/')
                if term.match(term_id)
                  concept_ids << [local_ncbo, virtual_id, term_id].join('/')
                  break
                end
              end
            end
            hash[member['resourceId']] = {'name' => Constants::RESOURCE_INDEX[member['resourceId']], 'count' => member['resultStatistics']['statistics']['annotationCount'].to_i, 'concept_ids' => concept_ids.join(',')}
          end
          hash
        end
      elsif result && result['errorStatus']
        raise NCBOException.new(result['errorStatus']['shortMessage'], result['errorStatus']['longMessage'])
      else
        raise NCBOException.new("Unknown NCBO Error", result)
      end
    end

    def resource_count(term_ids)
      result = NcboResourceService.get_data(term_ids)
      if result && result['success']
        result_array = result['success']['data']['list']['result']
        return annotation_count_sum(result_array)
      elsif result && result['errorStatus']
        raise NCBOException.new(result['errorStatus']['shortMessage'], result['errorStatus']['longMessage'])
      else
        raise NCBOException.new("Unknown NCBO Error", result)
      end
    end

    def annotation_count_sum(result_array)
      sum = 0
      result_array.each do |result|
        sum = sum + result['resultStatistics']['statistics']['annotationCount'].to_i
      end
      sum
    end

    def annotations_for_geo_accession(geo_accession)
      result = NcboResourceService.get_annotations(geo_accession)
      if result && result['success']
        annotation_array = result['success']['data']['resultDetailed']['mgrepAnnotations']['annotation'] + result['success']['data']['resultDetailed']['mappingAnnotations']['annotation']
        annotation_array.inject({}) do |hash, member|
          ncbo_current_id, term_id = member['concept']['localConceptId'].split('/')
          if (term_id =~ /^MA:.+/ || term_id =~ /^RS:.+/ || term_id =~ /^CL:.+/)
            ncbo_id = case term_id
              when /^MA:.+/
                1000
              when /^RS:.+/
                1150
              when /^CL:.+/
                1006
            end
            term_hash = {'geo_accession' => geo_accession, 'name' => member['concept']['preferredName'], 'field_name' => member['context']['contextName'].split('GEO_').last, 'matched_term' => member['context']['termName'], 'starts_at' => member['context']['from'], 'ends_at' => member['context']['to'], 'format' => (member['context']['isDirect'] == 'true') ? 'MGREP' : 'MAPPING', 'ncbo_id' => ncbo_id}
            if hash.has_key?(term_id)
              is_new = true
              hash[term_id].each do |existing|
                if ((existing['field_name'] == term_hash['field_name']))
                  is_new = false
                  break
                end
              end
              hash[term_id] << term_hash if is_new
            else
              hash[term_id] = [term_hash]
            end
          end
          hash
        end
      elsif result && result['errorStatus']
        raise NCBOException.new(result['errorStatus']['shortMessage'], result['errorStatus']['longMessage'])
      else
        raise NCBOException.new("Unknown NCBO Error", result)
      end
    end

  end # of class << self

end