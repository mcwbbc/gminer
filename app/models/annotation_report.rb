class AnnotationReport

  attr_accessor :ontology, :geoitem

  def setup(ontology, geoitem)
    @ontology = ontology
    @geoitem = geoitem
  end

  class << self
    def manual_terms
      annotations = Annotation.manual
      results = annotations.inject([]) do |a, an|
        hash = {:term_id => an.ontology_term.term_id.split("|").last, :term_name => an.ontology_term.name, :term_text => an.term_text, :ncbo_id => an.ncbo_id, :from => an.from, :to => an.to, :geo_accession => an.geo_accession, :field_name => an.field_name}
        a << hash
        a
      end
    end
  end

  def valid
    conditions = "AND annotations.status = 'audited' AND annotations.verified = 1"
    query(conditions)
  end

  def invalid
    conditions = "AND annotations.status = 'audited' AND annotations.verified = 0"
    query(conditions)
  end

  def unaudited
    conditions = "AND annotations.status = 'unaudited'"
    query(conditions)
  end

  def results
    v = valid
    i = invalid
    u = unaudited
    fields = [v.map{|x| x.field_name}+i.map{|x| x.field_name}+u.map{|x| x.field_name}].flatten.uniq
    final = {}
    fields.each do |field_name|
      final[field_name] = {:valid => [], :invalid => [], :unaudited => []}
      final[field_name][:valid] << v.inject([]) {|a,vt| a << "#{vt.name}(#{vt.count})" if vt.field_name == field_name; a}
      final[field_name][:invalid] << i.inject([]) {|a,it| a << "#{it.name}(#{it.count})" if it.field_name == field_name; a}
      final[field_name][:unaudited] << u.inject([]) {|a,ut| a << "#{ut.name}(#{ut.count})" if ut.field_name == field_name; a}
      final[field_name][:valid].flatten!
      final[field_name][:invalid].flatten!
      final[field_name][:unaudited].flatten!
    end
    [fields, final]
  end


  protected

    def query(conditions)
      sql = "SELECT ontology_terms.name, annotations.field_name, ontology_terms.term_id, count(ontology_terms.name) AS count FROM annotations"
      sql << " LEFT OUTER JOIN ontologies ON annotations.ontology_id = ontologies.id LEFT OUTER JOIN ontology_terms ON annotations.ontology_term_id = ontology_terms.id"
      sql << " WHERE (ontologies.ncbo_id = '#{ontology}' #{set_geotype_conditions} #{conditions})"
      sql << " GROUP BY annotations.field_name, ontology_terms.name"
      sql << " ORDER BY annotations.field_name, ontology_terms.name"
      annotations = Annotation.find_by_sql(sql)
    end

    def set_geotype_conditions
      case geoitem
        when "Platform"
          " AND annotations.geo_accession LIKE 'GPL%'"
        when "Sample"
          " AND annotations.geo_accession LIKE 'GSM%'"
        when "Series"
          " AND annotations.geo_accession LIKE 'GSE%'"
        when "Dataset"
          " AND annotations.geo_accession LIKE 'GDS%'"
      end
    end

end
