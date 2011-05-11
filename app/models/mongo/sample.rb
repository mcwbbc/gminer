module Mongo
  class Sample
    include Mongoid::Document
    include Abstract::Sample

    field :series_item_id
    field :platform_id
    field :geo_accession
    field :sample_type
    field :source_name
    field :organism
    field :label
    field :molecule
    field :title
    field :characteristics
    field :treatment_protocol
    field :extract_protocol
    field :label_protocol
    field :scan_protocol
    field :hyp_protocol
    field :description
    field :data_processing

    referenced_in :platform, :class_name => "Mongo::Platform"
    referenced_in :series_item, :class_name => "Mongo::SeriesItem"
    embeds_many :annotations, :class_name => "Mongo::Annotation"

  end
end