module Abstract
  module Platform
    include Cytoscape

    def persist
      download_file
      self.title = join_item(platform_hash["title"])
      self.organism = join_item(platform_hash["organism"])
      save!
      self
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
      data = GeoService.get("/geo/query/acc.cgi", :query => {"targ" => "self", "form" => "text", "view" => "brief", "acc" => "#{self.geo_accession}"}, :format => :plain)
      write_file(platform_filename, data)
    end

    def field_array
      fields = [
        {:name => "title", :annotatable => true, :value => title, :regex => /^!Platform_title = (.+?)$/},
        {:name => "organism", :annotatable => true, :value => organism, :regex => /^!Platform_organism = (.+?)$/},
        {:name => "series_ids", :annotatable => false, :value => "", :regex => /^!Platform_series_id = (GSE\d+)/}
      ]
    end

    def platform_hash
      @platform_hash ||= file_hash(field_array, platform_filename)
    end

  end
end
