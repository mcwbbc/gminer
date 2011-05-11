module Utilities

  module ClassMethods

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => :geo_accession,
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def page_for_tags(tags, conditions, exclude, page=1, size=Constants::PER_PAGE)
      options = (exclude == "false") ? {:exclude => true} : {}
      resource = tags.empty? ? all : tagged_with(tags, options)
      resource.paginate(:order => 'annotations.geo_accession',
       :readonly => true,
       :group => 'annotations.geo_accession',
       :include => [:tags],
       :joins => "INNER JOIN annotations ON annotations.geo_accession = #{self.table_name}.geo_accession",
       :conditions => conditions,
       :page => page,
       :per_page => size
       )
    end

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

    def strip_newlines(text)
      text.gsub(/[\r\n]+/, " ")
    end

    def annotation_count_array
      hash = self.field_names.inject({}) do |h, field_name|
        h[field_name] = Annotation.count(:conditions => ["geo_accession LIKE ? AND field_name = ?", "#{Constants::MODEL_GEO_PREFIXES[self.name]}%", field_name])
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
          m = Gminer::Platform
        when /^GDS/
          m = Dataset
      end
      m.first(:select => '*', :conditions => {:geo_accession => key})
    end

    def convert_to_field_ontology_hash(items)
      items.inject({}) do |h, item|
        if h.has_key?(item.field_name)
          if h[item.field_name].has_key?(item.ontology.name)
            h[item.field_name][item.ontology.name] << item
          else
            h[item.field_name][item.ontology.name] = [item]
          end
        else
          h[item.field_name] = {item.ontology.name => [item]}
        end
        h
      end
    end

  end #end of ClassMethods

  def corrected_field_name
    case field_name
      when 'description'
        'summary'
      else
        field_name
    end
  end

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

  def annotations_for(field_name)
#    annotations = Annotation.all(:conditions => ["annotations.geo_accession = ? AND annotations.field_name = ? AND annotations.ontology_term_id != ?", self.geo_accession, field_name, "none"], :include => [{:ontology_term => :ontology}], :order => "ontologies.name, ontology_terms.name")
    query = "SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t"
    query << " WHERE a.geo_accession = '#{self.geo_accession}'"
    query << " AND a.field_name = '#{field_name}'"
    query << " AND a.ontology_term_id != -1"
    query << " AND a.ontology_term_id = t.id"
    query << " AND t.ncbo_id = o.ncbo_id"
    query << " ORDER BY o.name, t.name"
    Annotation.find_by_sql(query)
  end

  def prev_next
    geo_accessions = Constants::GEO_ACCESSION_IDS[self.class.name]
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

  def tags_for
    case geo_accession
      when /^GSM/
        m = Sample
      when /^GSE/
        m = SeriesItem
      when /^GPL/
        m = Gminer::Platform
      when /^GDS/
        m = Dataset
    end
    m.first(:select => '*', :conditions => {:geo_accession => geo_accession}).tag_list
  end

end