module Abstract
  module Dataset
    include FileUtilities
    extend FileUtilities::ClassMethods
    include Cytoscape

    def to_param
      self.geo_accession
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

    def field_array
      fields = [
        {:name => "organism", :annotatable => true, :value => organism, :regex => /^!dataset_platform_organism = (.+?)$/},
        {:name => "title", :annotatable => true, :value => title, :regex => /^!dataset_title = (.+?)$/},
        {:name => "description", :annotatable => true, :value => description, :regex => /^!dataset_description = (.+?)$/},
        {:name => "pubmed_id", :annotatable => false, :value => pubmed_id, :regex => /^!dataset_pubmed_id = (\d+)$/},
        {:name => "reference_series", :annotatable => false, :value => "", :regex => /^!dataset_reference_series = (GSE\d+)$/},
        {:name => "platform_geo_accession", :annotatable => false,  :value => "", :regex => /^!dataset_platform = (GPL\d+)$/},
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

    def dataset_hash
      file_hash(field_array, local_dataset_filename)
    end

  end
end
