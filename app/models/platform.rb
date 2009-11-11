class Platform < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  include HTTParty
    base_uri 'www.ncbi.nlm.nih.gov'

  has_many :series_items
  has_many :samples, :through => :series_items
  has_many :annotations, :foreign_key => :geo_accession, :primary_key => :geo_accession

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:geo_accession],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
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

  def to_param
    self.geo_accession
  end

  def platform_path
    "#{Rails.root}/datafiles/#{self.geo_accession}"
  end

  def platform_filename
    "#{platform_path}/#{self.geo_accession}.soft"
  end

  def download_file
    make_directory(platform_path)
    data = Platform.get("/geo/query/acc.cgi", :query => {"targ" => "self", "form" => "text", "view" => "brief", "acc" => "#{self.geo_accession}"}, :format => :plain)
    write_file(platform_filename, data)
  end

  def download_series_files
    download_file
    platform_hash["series_ids"].each do |series_id|
      s = SeriesItem.new(:geo_accession => series_id, :platform_id => self.id)
      s.download
    end
  end

  def persist
    download_file
    self.title = join_item(platform_hash["title"])
    self.organism = join_item(platform_hash["organism"])
    save!
  end

  def create_series(array=platform_hash["series_ids"])
    Detection.disable_keys
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
    stime = Time.now
    Detection.enable_keys
    puts "enable keys took: #{Time.now-stime}"
  end

  def fields
    fields = [
      {:name => "title", :value => title, :regex => /^!Platform_title = (.+?)$/},
      {:name => "organism", :value => organism, :regex => /^!Platform_organism = (.+?)$/},
      {:name => "series_ids", :value => "", :regex => /^!Platform_series_id = (GSE\d+)/}
    ]
  end

  def platform_hash
    file_hash(fields, platform_filename)
  end

end
