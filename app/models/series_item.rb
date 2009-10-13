class SeriesItem < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :platform
  has_many :samples

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:geo_accession],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end
  end

  def to_param
    self.geo_accession
  end

  def series_path
    "#{Rails.root}/datafiles/#{self.platform.geo_accession}/#{self.geo_accession}"
  end

  def family_filename
    "#{self.geo_accession}_family.soft"
  end

  def local_family_filename
    "#{series_path}/#{family_filename}"
  end

  def local_series_filename
    "#{series_path}/#{self.geo_accession}_series.soft"    
  end

  def download
    if !File.exists?("#{local_family_filename}")
      download_file
      split_series_file
    end
  end

  def persist
    download
    self.overall_design = join_item(series_hash["overall_design"])
    self.title = join_item(series_hash["title"])
    self.summary = join_item(series_hash["summary"])
    self.pubmed_id = join_item(series_hash["pubmed_id"])
    save!
  end

  def download_file
    make_directory(series_path)
    Net::FTP.open('ftp.ncbi.nih.gov') do |ftp|
      ftp.login
      ftp.passive = true
      files = ftp.chdir("/pub/geo/DATA/SOFT/by_series/#{self.geo_accession}")
      ftp.getbinaryfile("#{family_filename}.gz", "#{local_family_filename}.gz", 1024)
    end
    gunzip("#{local_family_filename}.gz")
  end

  def fields
    fields = [
      {:name => "title", :value => title, :regex => /^!Series_title = (.+)$/},
      {:name => "summary", :value => summary, :regex => /^!Series_summary = (.+)$/},
      {:name => "overall_design", :value => overall_design, :regex => /^!Series_overall_design = (.+?)$/},
      {:name => "pubmed_id", :value => pubmed_id, :regex => /^!Series_pubmed_id = (\d+)$/},
      {:name => "sample_ids", :value => "", :regex => /^!Series_sample_id = (GSM\d+)$/}
    ]
  end

  def series_hash
    file_hash(fields, local_series_filename)
  end

  def create_samples(array=series_hash["sample_ids"])
    array.each do |sample_id|
      sam = Sample.first(:conditions => {:geo_accession => sample_id})
      if !sam
        stime = Time.now
        puts "creating sample #{sample_id}"
        Sample.transaction do
          sam = Sample.new(:platform_id => self.platform_id, :series_item_id => self.id, :geo_accession => sample_id)
          sam.persist
          sam.create_detections
        end
        puts "Took: #{Time.now-stime}"
      end
    end
  end

  def split_series_file
    text = ""
    outfile = local_series_filename
    start = /^\^SAMPLE = (GSM\d+)$/
    platform_start = /^\^PLATFORM = (GPL\d+)$/
    platform_end = /^!platform_table_end$/
    platform_flag = false

    File.open(local_family_filename, "r").each do |line|
      platform_flag = true if line =~ platform_start
      if m = line.match(start)
        write_file(outfile, text)
        text = ""
        outfile = "#{series_path}/#{m[1]}_sample.soft"
      end
      text << line if !platform_flag
      platform_flag = false if line =~ platform_end
    end
    write_file(outfile, text)
  end

end
