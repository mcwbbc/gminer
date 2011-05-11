class ResourceIndexAnnotation < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :ontology_term, :foreign_key => :term_id, :primary_key => :term_id
  belongs_to :ontology, :foreign_key => :ncbo_id, :primary_key => :ncbo_id

  class << self

    def exclusive_for(geo_accession)
      identifiers = Annotation.select(:identifier).where(:geo_accession => geo_accession).map {|a| a.identifier.gsub('description', 'summary') }.uniq
      rias = where(:geo_accession => geo_accession).where("identifier NOT IN (#{identifiers.to_in_query_string})")
      convert_to_field_ontology_hash(rias)
    end

# select annotations.* from resource_index_annotations, annotations
# where resource_index_annotations.geo_accession = "GDS3224"
# and annotations.geo_accession = "GDS3224"
# and resource_index_annotations.identifier != annotations.identifier
# group by annotations.identifier

    def save_from_hash(hash)
      hash.keys.each do |key|
        hash[key].each do |element|
          term_id = [element['ncbo_id'], key].join('|')
          annotation = ResourceIndexAnnotation.new(
          :identifier => [element['geo_accession'], element['field_name'], term_id].join("-"),
          :from => element['starts_at'], :to => element['ends_at'], :geo_accession => element['geo_accession'],
          :field_name => element['field_name'], :term_id => term_id, :ncbo_id => element['ncbo_id'])
          begin
            annotation.save
          rescue ActiveRecord::RecordNotUnique
          end
        end
      end
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => 'geo_accession',
               :group => 'geo_accession',
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

  end

  def audited?
    nil
  end

  def created_by_id
    0
  end

end
