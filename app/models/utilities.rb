module Utilities

  module ClassMethods

    def disable_keys
      sql = "ALTER TABLE #{name.to_s.tableize} DISABLE KEYS;"
      ActiveRecord::Base.connection.execute(sql)
    end

    def enable_keys
      sql = "ALTER TABLE #{name.to_s.tableize} ENABLE KEYS;"
      ActiveRecord::Base.connection.execute(sql)
    end

    def field_names
      array = self.column_names
      array.delete("id")
      array
    end

    def persist(geo_accession, force=false)
      record = self.first(:conditions => {:geo_accession => geo_accession})
      if !record
        record = self.new(:geo_accession => geo_accession)
      end
      record.persist if (record.new_record? || force)
    end

    def strip_newlines(text)
      text.gsub(/[\r\n]+/, " ")
    end

    def annotation_count_array
      hash = self.field_names.inject({}) do |h, field|
        h[field] = Annotation.count(:conditions => ["geo_accession LIKE ? AND field = ?", "#{Constants::MODEL_GEO_PREFIXES[self.name]}%", field])
        h
      end
      array = hash.sort_by { |k,v| v }
      array.reverse.map { |a| {:name => a[0], :amount => a[1]} }
    end

    def load_item(key)
      case key
        when /^GSM/
          m = Sample
        when /^GSE/
          m = SeriesItem
        when /^GPL/
          m = Platform
        when /^GDS/
          m = Dataset
      end
      m.first(:conditions => {:geo_accession => key})
    end
  end #end of ClassMethods

  def count_by_ontology_array
    hash = {}
    Constants::ONTOLOGIES.keys.each do |key|
      hash[Constants::ONTOLOGIES[key][:name]] = 0
    end

    ontology_hash = Ontology.all.inject({}) do |h, ontology|
      h[ontology.id] = ontology.name
      h
    end

    annotations.each do |annotation|
      if ontology_hash.has_key?(annotation.ontology_id)
        count = hash[ontology_hash[annotation.ontology_id]] || 0
        hash[ontology_hash[annotation.ontology_id]] = count + 1
      end
    end

    array = hash.sort_by { |k,v| v }
    array.reverse.map { |a| {:name => a[0], :amount => a[1]} }
  end

  def join_item(item)
    item.is_a?(Array) ? item.join(' ') : item
  end

  def annotations_for(field)
#    annotations = Annotation.all(:conditions => ["annotations.geo_accession = ? AND annotations.field = ? AND annotations.ontology_term_id != ?", self.geo_accession, field, "none"], :include => [{:ontology_term => :ontology}], :order => "ontologies.name, ontology_terms.name")
    query = "SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t"
    query << " WHERE a.geo_accession = '#{self.geo_accession}'"
    query << " AND a.field = '#{field}'"
    query << " AND a.ontology_term_id != -1"
    query << " AND a.ontology_term_id = t.id"
    query << " AND t.ncbo_id = o.ncbo_id"
    query << " ORDER BY o.name, t.name"
    Annotation.find_by_sql(query)
  end

  def make_directory(target)
    Dir.mkdir(target) unless File.exists?(target)
  end

  def remove_item(directory)
    FileUtils.rm_r(directory) if File.exists?(directory)
  end

  def gunzip(filename)
    command = "gunzip --force #{filename}"
    success = system(command)
    success && $?.exitstatus == 0
  end

  def write_file(filename, text)
    File.open(filename, 'w') do |out|
      out.write(text)
    end
  end

  def file_hash(matchers, filename)
    hash = matchers.inject({}) {|h, matcher| h[matcher[:name]] = []; h}
    File.open(filename, "r").each do |line|
      matchers.each do |matcher|
        if m = line.match(matcher[:regex])
          hash[matcher[:name]] << m[1].chomp
          break
        end
      end
    end
    hash
  end

  def prev_next
    geo_accessions = self.class.all(:order => [:geo_accession]).map { |item| item.geo_accession }
    i = geo_accessions.index(self.geo_accession)
    [geo_accessions[i-1], geo_accessions[i+1]]
  end

  def descriptive_text
    case self.geo_accession
      when /^GSM/
        "#{self.series_item.title} - #{self.title}"
      when /^GSE/
        self.title
      when /^GPL/
        self.title
      when /^GDS/
        self.title
    end
  end

end