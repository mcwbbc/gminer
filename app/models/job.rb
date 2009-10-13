class Job < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :ontology

  class << self

    def available(*hash)
      hash = hash.any? ? hash.first : {}
      options = {:expired_at => 2.weeks.ago, :crashed_at => 5.minutes.ago}.merge!(hash)
      if options[:count]
        Job.count(:conditions => ["(worker_key IS NULL AND (finished_at IS NULL OR finished_at < ?)) OR (worker_key IS NOT NULL AND started_at < ?)", options[:expired_at], options[:crashed_at]])
      else
        Job.first(:conditions => ["(worker_key IS NULL AND (finished_at IS NULL OR finished_at < ?)) OR (worker_key IS NOT NULL AND started_at < ?)", options[:expired_at], options[:crashed_at]])
      end
    end

    def create_for(geo_accession, ontology_id, field)
      item = Job.load_item(geo_accession)
      if !j = Job.first(:conditions => {:geo_accession => geo_accession, :field => field, :ontology_id => ontology_id})
        Job.create(:geo_accession => geo_accession, :field => field, :ontology_id => ontology_id)
      end
    end

  end


end
