class CreateClosureAnnotationsJob < Struct.new(:annotation_id)

  def perform
    annotation = Annotation.find(annotation_id)
    create_for(annotation, annotation.ontology_term.name, annotation.ncbo_id, [Constants::STOPWORDS, annotation.ontology_term.ontology.stopwords].join(","), annotation.ontology_term.ontology.expand_ontologies, "email@mcw.edu")
  end

  def create_for(annotation, field_value, ncbo_id, stopwords, expand_ontologies, email)
    cleaned = field_value.gsub(/[\r\n]+/, " ")
    term_hash, ontology_hash = NCBOAnnotatorService.result_hash(cleaned, stopwords, expand_ontologies, ncbo_id, email)
    process_ncbo_results(annotation, term_hash, ontology_hash, field_value)
  end

  def process_ncbo_results(annotation, hash, ontology_hash, field_value)
    process_closure(annotation, hash["ISA_CLOSURE"], ontology_hash)
  end

  def process_closure(annotation, hash, ontology_hash)
    hash.keys.each do |key|
      hash[key].each do |closure|
        current_ncbo_id, term_id = closure[:id].split("|")
        key_current_ncbo_id, key_term_id = key.split("|")
        ncbo_id = ontology_hash[closure[:local_ontology_id]]

        term_id = "#{ncbo_id}|#{term_id}"
        ncbo_id = ncbo_id.to_i
        term_name = closure[:name]

        if !ot = OntologyTerm.first(:conditions => {:term_id => term_id})
          ontology = Ontology.first(:conditions => {:ncbo_id => ncbo_id})
          ot = ontology.ontology_terms.create(:term_id => term_id, :ncbo_id => ncbo_id, :name => term_name) if ontology
        end

        closure_term = "#{ncbo_id}|#{term_id}"
        ct = OntologyTerm.first(:conditions => {:term_id => closure_term})
        if ct && !ac = annotation.annotation_closures.first(:conditions => {:ontology_term_id => ct.id})
          annotation.annotation_closures.create(:ontology_term_id => ct.id)
        end
      end
    end
  end

end
