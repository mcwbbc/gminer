class SeriesItem < ActiveRecord::Base
  include Abstract::SeriesItem
  include Utilities
  extend Utilities::ClassMethods

  acts_as_taggable_on :tags

  belongs_to :platform, :class_name => "Gminer::Platform"
  has_many :samples, :dependent => :delete_all
  has_many :annotations, :foreign_key => :geo_accession, :primary_key => :geo_accession
  has_one :dataset, :foreign_key => :reference_series, :primary_key => :geo_accession

  def self.load_series_items
    @series_items ||= begin
      if RedisConnection.db.exists('series_items-geo-accessions')
        RedisConnection.db.smembers('series_items-geo-accessions').sort
      else
        SeriesItem.all.map { |item| item.geo_accession }.each do |id|
          RedisConnection.db.sadd('series_items-geo-accessions', id)
        end
      end
    end
  end

  def create_samples(array=series_hash["sample_ids"], build_detections=false)
    @probeset_id_hash = Probeset.all.inject({}) {|h, p| h[p.name] = p.id; h } if build_detections
    array.each do |sample_id|
      if !sam = Sample.first(:conditions => {:geo_accession => sample_id})
        sam = Sample.new(:platform_id => self.platform_id, :series_item_id => self.id, :geo_accession => sample_id)
        sam.persist
        if build_detections
          stime = Time.now
          puts "creating sample #{sample_id}"
          sam.create_detections(@probeset_id_hash)
          puts "Took: #{Time.now-stime}"
        end
      end
    end
  end

end
