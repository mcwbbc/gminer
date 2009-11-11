class Job < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :ontology

  attr_accessor :geo_type, :fields

  class << self

    def get_statistics
#      x = {"Platform" => {:count => 4, :average_time => 0, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Dataset" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Sample" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Series" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}}}

      geo_items = {"Platform" => {:prefix => "GPL"}, "Dataset" => {:prefix => "GDS"}, "Sample" => {:prefix => "GSM"}, "Series" => {:prefix => "GSE"}}
      hash = {}
      geo_items.keys.each do |geo|
        c_string = "geo_accession LIKE ?"
        @geo_prefix = "#{geo_items[geo][:prefix]}%"
        @full_time_calculation = "finished_at-started_at"
        @annotator_time_calculation = "finished_at-working_at"
        conditions = [c_string, @geo_prefix]
        count = Job.count(:conditions => conditions)

        average_time = '%.5f' % (Job.average(@full_time_calculation, :conditions => conditions) || 0)
        annotator_average_time = '%.5f' % (Job.average(@annotator_time_calculation, :conditions => conditions) || 0)

        field_names = Job.all(:select => :field, :conditions => conditions, :group => :field).collect {|job| job.field}
        field_names_hash = field_names.inject({}) {|h, f| h[f] = {:count => 0, :ontology_ids => {}}; h}
        hash[geo] = {:count => count, :average_time => average_time, :annotator_average_time => annotator_average_time, :field_names => field_names_hash}

        field_names.each do |field_name|
          c_string = "geo_accession LIKE ? AND field = ?"
          conditions = [c_string, @geo_prefix, field_name]
          count = Job.count(:conditions => conditions)

          average_time = '%.5f' % (Job.average(@full_time_calculation, :conditions => conditions) || 0)
          annotator_average_time = '%.5f' % (Job.average(@annotator_time_calculation, :conditions => conditions) || 0)

          ontology_ids = Job.all(:select => :ontology_id, :conditions => conditions, :group => :ontology_id).collect {|job| job.ontology_id}
          ontology_ids_hash = ontology_ids.inject({}) {|h, id| h[id] = {:count => 0}; h}
          hash[geo][:field_names][field_name] = {:count => count, :average_time => average_time, :annotator_average_time => annotator_average_time, :ontology_ids => ontology_ids_hash}

          ontology_ids.each do |ontology_id|
            c_string = "geo_accession LIKE ? AND field = ? AND ontology_id = ?"
            conditions = [c_string, @geo_prefix, field_name, ontology_id]
            count = Job.count(:conditions => conditions)

            average_time = '%.5f' % (Job.average(@full_time_calculation, :conditions => conditions) || 0)
            annotator_average_time = '%.5f' % (Job.average(@annotator_time_calculation, :conditions => conditions) || 0)

            hash[geo][:field_names][field_name][:ontology_ids][ontology_id] = {:count => count, :average_time => average_time, :annotator_average_time => annotator_average_time, :name => Ontology.find(ontology_id).name}
          end
        end
      end
      hash
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "jobs.finished_at",
               :conditions => conditions,
               :joins => [:ontology],
               :page => page,
               :per_page => size
               )
    end

    def create_for(geo_accession, ontology_id, field)
      if !j = Job.first(:conditions => {:geo_accession => geo_accession, :field => field, :ontology_id => ontology_id})
        Job.create(:geo_accession => geo_accession, :field => field, :ontology_id => ontology_id)
      end
    end
  end

  def has_annotation?
    Annotation.first(:conditions => {:geo_accession => self.geo_accession, :field => self.field})
  end

end
