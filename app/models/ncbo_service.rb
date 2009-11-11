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
  end
end
