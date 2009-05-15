class Platform
  include Utilities
  extend Utilities::ClassMethods
  include DataMapper::Resource

  include HTTParty
    base_uri 'www.ncbi.nlm.nih.gov'
  
  property :geo_accession, String, :length => 25, :key => true
  property :title, String, :length => 255
  property :organism, String, :length => 255

  has n, :series_items, :child_key => [:platform_geo_accession]
  has n, :samples, :through => :series_items

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:geo_accession],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end
  end

  def platform_path
    "#{Constants::DATAFILES_PATH}/#{self.geo_accession}"
  end

  def platform_filename
    "#{platform_path}/#{self.geo_accession}.soft"
  end

  def download
    download_file if !File.exists?(platform_filename)
  end

  def download_file
    make_directory(platform_path)
    data = Platform.get("/geo/query/acc.cgi", :query => {"targ" => "self", "form" => "text", "view" => "brief", "acc" => "#{self.geo_accession}"}, :format => :plain)
    write_file(platform_filename, data)
  end

  def download_series_files
    download
    platform_hash["series_ids"].each do |series_id|
      s = SeriesItem.new(:geo_accession => series_id, :platform_geo_accession => self.geo_accession)
      s.download
    end
  end

  def persist
    download
    self.title = join_item(platform_hash["title"])
    self.organism = join_item(platform_hash["organism"])
    save!
  end

  def create_series(array=platform_hash["series_ids"])
    array.each do |series_id|
      ser = SeriesItem.first(:geo_accession => series_id)
      if !ser
        puts "creating series #{series_id}"
        ser = SeriesItem.new(:geo_accession => series_id, :platform_geo_accession => self.geo_accession)
      else
        puts "updating series #{series_id}"
      end
      ser.persist
      ser.create_samples
    end
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
