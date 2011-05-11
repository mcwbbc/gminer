module Mongo
  class Platform
    include Mongoid::Document
    include Abstract::Platform
    include FileUtilities
    extend FileUtilities::ClassMethods

    field :geo_accession
    field :title
    field :organism

    references_many :series_items, :class_name => "Mongo::SeriesItem"
    references_many :samples, :class_name => "Mongo::Sample"

    embeds_many :annotations, :class_name => "Mongo::Annotation"

    def create_series(array=platform_hash["series_ids"])
      array.each do |series_id|
        if !ser = Mongo::SeriesItem.first(:conditions => {:geo_accession => series_id})
          puts "creating mongo_series #{series_id}"
          ser = Mongo::SeriesItem.new(:geo_accession => series_id, :platform_id => self.id)
        else
          puts "updating mongo_series #{series_id}"
        end
        ser.persist
        ser.create_samples
      end
    end

  end
end