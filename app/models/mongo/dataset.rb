module Mongo
  class Dataset
    include Mongoid::Document
    include Abstract::Dataset
    include FileUtilities
    extend FileUtilities::ClassMethods

    field :platform_id
    field :geo_accession
    field :reference_series
    field :pubmed_id
    field :organism
    field :title
    field :description

    referenced_in :platform, :class_name => "Mongo::Platform"
    referenced_in :series_item, :class_name => "Mongo::SeriesItem"
    embeds_many :annotations, :class_name => "Mongo::Annotation"

    def persist
      download
      self.organism = join_item(dataset_hash["organism"])
      self.title = join_item(dataset_hash["title"])
      self.description = join_item(dataset_hash["description"])
      self.pubmed_id = join_item(dataset_hash["pubmed_id"])
      self.reference_series = join_item(dataset_hash["reference_series"])
      platform = Mongo::Platform.first(:conditions => {:geo_accession => join_item(dataset_hash["platform_geo_accession"])} )
      self.platform_id = platform.id
      save!
    end

  end
end