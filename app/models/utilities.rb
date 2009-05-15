module Utilities

  module ClassMethods

    def find_in_batches(options = {})
      batch_size = options.delete(:batch_size) || 1000
      count = self.count
      0.upto(count/batch_size) do |i|

        offset = (i*batch_size)+1
        records = self.all(:limit => batch_size, :offset => offset)

        yield records
      end
    end

    def field_names
      array = self.properties.map { |property| property.name.to_s }
      array.delete("id")
      array
    end

    def persist(geo_accession)
      record = self.first(:geo_accession => geo_accession)
      if !record
        record = self.new(:geo_accession => geo_accession)
        record.persist
      end
    end

    def remove_stopwords(text)
      Constants::STOPWORDS.split(",").each do |word|
        text.gsub!(/(^|\s)(#{word})(\s|$)/i, " ")
      end
      text
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
      m.get(key)
    end

  end

  def create_annotations
    Annotation.create_for(self.geo_accession, fields, descriptive_text)
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

  def join_item(item)
    item.is_a?(Array) ? item.join(' ') : item
  end

  def annotations
#    Annotation.find(:all, :conditions => ["annotations.geo_accession = ? AND annotations.ontology_term_id != ?", self.geo_accession, "none"], :include => :ontology_term, :order => "ontology_terms.name", :group => "ontology_terms.term_id")
    query = "SELECT a.* FROM annotations AS a, ontology_terms AS t"
    query << " WHERE a.geo_accession = '#{self.geo_accession}'"
    query << " AND a.ontology_term_id != 'none'"
    query << " AND a.ontology_term_id = t.term_id"
    query << " ORDER BY t.term_id"
    Annotation.find_by_sql(query)
  end

  def annotations_for(field)
#    annotations = Annotation.all(:conditions => ["annotations.geo_accession = ? AND annotations.field = ? AND annotations.ontology_term_id != ?", self.geo_accession, field, "none"], :include => [{:ontology_term => :ontology}], :order => "ontologies.name, ontology_terms.name")
    query = "SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t"
    query << " WHERE a.geo_accession = '#{self.geo_accession}'"
    query << " AND a.field = '#{field}'"
    query << " AND a.ontology_term_id != 'none'"
    query << " AND a.ontology_term_id = t.term_id"
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

end