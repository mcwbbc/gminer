class AnnotationClosure < ActiveRecord::Base

  belongs_to :annotation
  belongs_to :ontology_term

  class << self

    def persist(geo_accession, field_name, term_id, closure_term)
      ot = OntologyTerm.first(:conditions => {:term_id => term_id})
      if ot && a = ot.annotations.first(:conditions => {:geo_accession => geo_accession, :field => field_name})
        ct = OntologyTerm.first(:conditions => {:term_id => closure_term})
        if ct && !ac = a.annotation_closures.first(:conditions => {:ontology_term_id => ct.id})
          a.annotation_closures.create(:ontology_term_id => ct.id)
        end
      end
    end

  end

end
