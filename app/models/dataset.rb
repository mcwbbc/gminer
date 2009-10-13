class Dataset < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  belongs_to :platform, :foreign_key => :platform_geo_accession
  belongs_to :series_item, :foreign_key => :reference_series

  def to_param
    self.geo_accession
  end

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:geo_accession],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end
  end

  def dataset_path
    "#{Rails.root}/datafiles/#{self.geo_accession}"
  end

  def dataset_filename
    "#{self.geo_accession}.soft"
  end

  def local_dataset_filename
    "#{dataset_path}/#{dataset_filename}"
  end

  def fields
    fields = [
      {:name => "organism", :value => organism, :regex => /^!dataset_platform_organism = (.+?)$/},
      {:name => "title", :value => title, :regex => /^!dataset_title = (.+?)$/},
      {:name => "description", :value => description, :regex => /^!dataset_description = (.+?)$/},
      {:name => "pubmed_id", :value => pubmed_id, :regex => /^!dataset_pubmed_id = (\d+)$/},
      {:name => "reference_series", :value => "", :regex => /^!dataset_reference_series = (GSE\d+)$/},
      {:name => "platform_geo_accession", :value => "", :regex => /^!dataset_platform = (GPL\d+)$/},
    ]
  end

  def download
    download_file if !File.exists?(local_dataset_filename)
  end

  def download_file
    make_directory(dataset_path)
    Net::FTP.open('ftp.ncbi.nih.gov') do |ftp|
      ftp.login
      ftp.passive = true
      files = ftp.chdir("/pub/geo/DATA/SOFT/GDS")
      ftp.getbinaryfile("#{dataset_filename}.gz", "#{local_dataset_filename}.gz", 1024)
    end
    gunzip("#{local_dataset_filename}.gz")
  end

  def persist
    download
    self.organism = join_item(dataset_hash["organism"])
    self.title = join_item(dataset_hash["title"])
    self.description = join_item(dataset_hash["description"])
    self.pubmed_id = join_item(dataset_hash["pubmed_id"])
    self.reference_series = join_item(dataset_hash["reference_series"])
    platform = Platform.first(:conditions => {:geo_accession => join_item(dataset_hash["platform_geo_accession"])} )
    self.platform_id = platform.id
    save!
  end

  def dataset_hash
    file_hash(fields, local_dataset_filename)
  end

end
