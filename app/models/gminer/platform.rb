module Gminer
  class Gminer::Platform < ActiveRecord::Base
    include Abstract::Platform
    include Utilities
    extend Utilities::ClassMethods
    include FileUtilities
    extend FileUtilities::ClassMethods

    acts_as_taggable_on :tags

    has_many :series_items, :dependent => :delete_all
    has_many :samples, :through => :series_items, :dependent => :delete_all
    has_many :annotations, :dependent => :delete_all, :foreign_key => :geo_accession, :primary_key => :geo_accession

    class << self

      def load_platform
        @platform ||= begin
          if RedisConnection.db.exists('platform-geo-accessions')
            RedisConnection.db.smembers('platform-geo-accessions').sort
          else
            Gminer::Platform.all.map { |item| item.geo_accession }.each do |id|
              RedisConnection.db.sadd('platform-geo-accessions', id)
            end
          end
        end
      end

      def for_probeset(probeset_name)
        find(
          :all,
          :select => "platforms.*",
          :joins => "INNER JOIN samples ON platforms.id = samples.platform_id INNER JOIN detections ON samples.id = detections.sample_id INNER JOIN probesets ON probesets.id = detections.probeset_id AND probesets.name = '#{probeset_name}'",
          :group  => "platforms.geo_accession",
          :order  => "platforms.geo_accession"
        )
      end

    end

    def set_children_status_to(status='skip')
      series_items.each do |si|
        si.annotations.each do |a|
          a.update_attribute('status', status) if !a.audited?
        end
      end

      samples.each do |s|
        s.annotations.each do |a|
          a.update_attribute('status', status) if !a.audited?
        end
      end
    end

    def create_series(array=platform_hash["series_ids"], build_detections=false)
      Detection.disable_keys if build_detections
      array.each do |series_id|
        ser = SeriesItem.first(:conditions => {:geo_accession => series_id})
        if !ser
          puts "creating series #{series_id}"
          ser = SeriesItem.new(:geo_accession => series_id, :platform_id => self.id)
        else
          puts "updating series #{series_id}"
        end
        ser.persist
        ser.create_samples
      end
      if build_detections
        stime = Time.now
        Detection.enable_keys
        puts "enable keys took: #{Time.now-stime}"
      end
    end

  end
end