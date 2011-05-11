class Job < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :ontology

  attr_accessor :geo_type, :fields

  class << self

    def pending_count
      count(:conditions => {:worker_key => nil, :started_at => nil, :finished_at => nil})
    end

    def active_count
      count(:conditions => ["worker_key IS NOT ? AND started_at IS NOT ? AND finished_at IS ?", nil, nil, nil])
    end

    def get_statistics
#      x = {"Platform" => {:count => 4, :average_time => 0, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Dataset" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Sample" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},"Series" => {:count => 4, :field_names => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}}}

      geo_items = {"Platform" => {:prefix => "GPL"}, "Dataset" => {:prefix => "GDS"}, "Sample" => {:prefix => "GSM"}, "Series" => {:prefix => "GSE"}}
      hash = {}
      geo_items.keys.each do |geo|
        c_string = "geo_accession LIKE ?"
        @geo_prefix = "#{geo_items[geo][:prefix]}%"
        conditions = [c_string, @geo_prefix]
        field_names = Job.all(:select => :field_name, :conditions => conditions, :group => :field_name).collect {|job| job.field_name}
        field_names_hash = field_names.inject({}) {|h, f| h[f] = {:count => 0, :ontology_ids => {}}; h}
        hash[geo] = {:field_names => field_names_hash}.merge!(stat_calculations(conditions))
        field_names.each do |field_name|
          c_string = "geo_accession LIKE ? AND field_name = ?"
          conditions = [c_string, @geo_prefix, field_name]
          ontology_ids = Job.all(:select => :ontology_id, :conditions => conditions, :group => :ontology_id).collect {|job| job.ontology_id}
          ontology_ids_hash = ontology_ids.inject({}) {|h, id| h[id] = {:count => 0}; h}
          hash[geo][:field_names][field_name] = {:ontology_ids => ontology_ids_hash}.merge!(stat_calculations(conditions))
          ontology_ids.each do |ontology_id|
            c_string = "geo_accession LIKE ? AND field_name = ? AND ontology_id = ?"
            conditions = [c_string, @geo_prefix, field_name, ontology_id]
            hash[geo][:field_names][field_name][:ontology_ids][ontology_id] = {:name => Ontology.find(ontology_id).name}.merge!(stat_calculations(conditions))
          end
        end
      end
      hash
    end

    def stat_calculations(conditions)
      full_time_calculation = "finished_at-started_at"
      annotator_time_calculation = "finished_at-working_at"
      count = Job.count(:conditions => conditions)
      ncbo_average_time = '%.5f' % (Job.average(annotator_time_calculation, :conditions => conditions) || 0)
      average_time = '%.5f' % (Job.average(full_time_calculation, :conditions => conditions) || 0)
      max_time = '%.5f' % (Job.maximum(full_time_calculation, :conditions => conditions) || 0)
      min_time = '%.5f' % (Job.minimum(full_time_calculation, :conditions => conditions) || 0)
#      std_dev = '%.5f' % (Job.calculate(:stddev_pop, full_time_calculation, :conditions => conditions) || 0)
      {:count => count, :average_time => average_time, :max_time => max_time, :min_time => min_time, :ncbo_average_time => ncbo_average_time}
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "jobs.finished_at",
               :conditions => conditions,
               :joins => [:ontology],
               :page => page,
               :per_page => size
               )
    end

    def create_for(geo_accession, ontology_id, field_name)
      if !j = Job.first(:conditions => {:geo_accession => geo_accession, :field_name => field_name, :ontology_id => ontology_id})
        Job.create(:geo_accession => geo_accession, :field_name => field_name, :ontology_id => ontology_id)
      end
    end
  end

  def geo_item_model
    case geo_type
      when "Platform"
        m = Gminer::Platform
      when "Sample"
        m = Sample
      when "Series"
        m = SeriesItem
      when "Dataset"
        m = Dataset
    end
    m
  end

  def model_fields
    geo_item_model.new.field_array.inject([]) { |a, f| a << f[:name] if f[:annotatable]; a }
  end

  def get_fields
    fields = model_fields.inject([]) do |a, field_name|
      a << {'name' => field_name, 'last_annotated' => last_annotated(field_name)}
      a
    end
  end

  def last_annotated(field_name)
    case geo_type
      when "Platform"
        geo_accession = "GPL%"
      when "Sample"
        geo_accession = "GSM%"
      when "Series"
        geo_accession = "GSE%"
      when "Dataset"
        geo_accession = "GDS%"
    end
    j = Job.find(:first, :conditions => ['ontology_id = ? AND geo_accession LIKE ? AND field_name = ?', ontology_id, geo_accession, field_name], :order => 'finished_at DESC')
    if j && j.finished_at
      Time.at(j.finished_at).to_s(:us_with_time)
    else
      "-"
    end
  end

  def has_annotation?
    Annotation.first(:conditions => {:geo_accession => self.geo_accession, :field_name => self.field_name})
  end

end
