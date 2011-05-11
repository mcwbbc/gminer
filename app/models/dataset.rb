class Dataset < ActiveRecord::Base
  include Abstract::Dataset
  include Utilities
  extend Utilities::ClassMethods
  include FileUtilities
  extend FileUtilities::ClassMethods

  acts_as_taggable_on :tags

  belongs_to :platform, :foreign_key => :platform_geo_accession, :class_name => "Gminer::Platform"
  belongs_to :series_item, :foreign_key => :reference_series, :primary_key => :geo_accession
  has_many :annotations, :foreign_key => :geo_accession, :primary_key => :geo_accession

  def self.load_dataset
    @dataset ||= begin
      if RedisConnection.db.exists('dataset-geo-accessions')
        RedisConnection.db.smembers('dataset-geo-accessions').sort
      else
        Dataset.all.map { |item| item.geo_accession }.each do |id|
          RedisConnection.db.sadd('dataset-geo-accessions', id)
        end
      end
    end
  end

  def persist
    download
    self.organism = join_item(dataset_hash["organism"])
    self.title = join_item(dataset_hash["title"])
    self.description = join_item(dataset_hash["description"])
    self.pubmed_id = join_item(dataset_hash["pubmed_id"])
    self.reference_series = join_item(dataset_hash["reference_series"])
    platform = Gminer::Platform.first(:conditions => {:geo_accession => join_item(dataset_hash["platform_geo_accession"])} )
    self.platform_id = platform.id
    save!
  end

end
