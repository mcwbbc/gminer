module Abstract
  module Sample
    include FileUtilities
    extend FileUtilities::ClassMethods
    include Cytoscape

    def persist
      self.attributes = sample_hash
      save!
      self
    end

    def to_param
      self.geo_accession
    end

    def series_path
      "#{Rails.root}/datafiles/#{self.platform.geo_accession}/#{self.series_item.geo_accession}"
    end

    def local_sample_filename
      "#{series_path}/#{self.geo_accession}_sample.soft"
    end

    def field_array
      fields = [
        {:name => "title", :annotatable => true, :value => title, :regex => /^!Sample_title = (.+)$/},
        {:name => "sample_type", :annotatable => true, :value => sample_type, :regex => /^!Sample_type = (.+?)$/},
        {:name => "source_name", :annotatable => true, :value => source_name, :regex => /^!Sample_source_name_ch1 = (.+?)$/},
        {:name => "organism", :annotatable => true, :value => organism, :regex => /^!Sample_organism_ch1 = (.+?)$/},
        {:name => "characteristics", :annotatable => true, :value => characteristics, :regex => /^!Sample_characteristics_ch1 = (.+?)$/},
        {:name => "treatment_protocol", :annotatable => true, :value => treatment_protocol, :regex => /^!Sample_treatment_protocol_ch1 = (.+?)$/},
        {:name => "extract_protocol", :annotatable => true, :value => extract_protocol, :regex => /^!Sample_extract_protocol_ch1 = (.+?)$/},
        {:name => "label", :annotatable => true, :value => label, :regex => /^!Sample_label_ch1 = (.+?)$/},
        {:name => "label_protocol", :annotatable => true, :value => label_protocol, :regex => /^!Sample_label_protocol_ch1 = (.+?)$/},
        {:name => "scan_protocol", :annotatable => true, :value => scan_protocol, :regex => /^!Sample_scan_protocol = (.+?)$/},
        {:name => "hyp_protocol", :annotatable => true, :value => hyp_protocol, :regex => /^!Sample_hyb_protocol = (.+?)$/},
        {:name => "description", :annotatable => true, :value => description, :regex => /^!Sample_description = (.+?)$/},
        {:name => "data_processing", :annotatable => true, :value => data_processing, :regex => /^!Sample_data_processing = (.+?)$/},
        {:name => "molecule", :annotatable => true, :value => molecule, :regex => /^!Sample_molecule_ch1 = (.+?)$/},
      ]
    end

    def sample_hash
      @sample_hash ||= begin
        hash = file_hash(field_array, local_sample_filename)
        hash.keys.each do |key|
          hash[key] = join_item(hash[key])
        end
        hash
      end
    end

  end
end
