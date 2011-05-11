module Mongo
  class SeriesItem
    include Mongoid::Document
    include Abstract::SeriesItem

    field :platform_id
    field :geo_accession
    field :pubmed_id
    field :title
    field :summary
    field :overall_design

    referenced_in :platform, :class_name => "Mongo::Platform"

    references_one :dataset, :class_name => "Mongo::Dataset"
    references_many :series_items, :class_name => "Mongo::SeriesItem"
    references_many :samples, :class_name => "Mongo::Sample"

    embeds_many :annotations, :class_name => "Mongo::Annotation"

    def create_samples(array=series_hash["sample_ids"])
      array.each do |sample_id|
        if !sam = Mongo::Sample.first(:conditions => {:geo_accession => sample_id})
          sam = Mongo::Sample.new(:platform_id => self.platform_id, :series_item_id => self.id, :geo_accession => sample_id)
          sam.persist
        end
      end
    end

  end
end

