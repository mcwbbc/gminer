module Cytoscape
  def cytoscape_hash
    @cytoscape_hash ||= begin
      hash = {'geo_accession' => self.geo_accession, 'format' => 'geo_record', 'node_id' => "geo_record_#{self.geo_accession}", 'annotations' => {}}
      annotations.each do |a|
        if hash['annotations'].has_key?(a.ontology.ncbo_id)
          if !hash['annotations'][a.ontology.ncbo_id]['ontology_terms'].has_key?(a.resource_id)
            if (!a.audited? || a.verified?)
              hash['annotations'][a.ontology.ncbo_id]['ontology_terms'][a.resource_id] = {'name' => a.ontology_term.name }.merge(format_hash(a))
            end
          end
        else
          if (!a.audited? || a.verified?)
            hash['annotations'][a.ontology.ncbo_id] = {'format' => 'ontology', 'name' => a.ontology.name, 'ontology_terms' => { a.resource_id => {'name' => a.ontology_term.name }.merge(format_hash(a)) }}
          end
        end
      end
      hash
    end
  end

  def format_hash(a)
    format = a.audited? ? (a.verified? ? "valid" : "invalid") : "unaudited"
    format = "human" if a.created_by_id != 0
    {'format' => format }
  end

  def cytoscape_data
    h = {'nodes' => [{'id' => cytoscape_hash['node_id'], 'label' => cytoscape_hash['geo_accession'], 'format' => cytoscape_hash['format']}], 'edges' => []}
    cytoscape_hash['annotations'].keys.each do |ncbo_id|
      cytoscape_hash['annotations'][ncbo_id]['ontology_terms'].keys.each do |ontology_term_id|
        h['nodes'] << {'id' => ontology_term_id, 'label' => cytoscape_hash['annotations'][ncbo_id]['ontology_terms'][ontology_term_id]['name'], 'format' => cytoscape_hash['annotations'][ncbo_id]['ontology_terms'][ontology_term_id]['format']}
        h['edges'] << {'id' => "#{ncbo_id}-#{ontology_term_id}", 'target' => ontology_term_id, 'source' => ncbo_id.to_s}
      end
      h['nodes'] << {'id' => ncbo_id.to_s, 'label' => cytoscape_hash['annotations'][ncbo_id]['name'], 'format' => cytoscape_hash['annotations'][ncbo_id]['format']}
      h['edges'] << {'id' => "#{cytoscape_hash['node_id']}-#{ncbo_id}", 'target' => ncbo_id.to_s, 'source' => cytoscape_hash['node_id']}
    end
    h
  end

  def resource_term_ids
    term_ids = []
    valid_annotations = annotations.map {|a| a.verified? ? a.resource_id : nil }.compact.uniq
    (valid_annotations.size).times do
      head = valid_annotations.shift
      valid_annotations.each do |a|
        term_ids << "#{head},#{a}"
      end
    end
    term_ids
  end


end



