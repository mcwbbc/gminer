class Probeset < ActiveRecord::Base

  has_many :detections
  has_many :samples, :through => :detections

  has_many :present_detections, :class_name => "Detection", :conditions => "detections.abs_call = 'P'"
  has_many :present_samples, :through => :present_detections, :source => :sample

  has_many :absent_detections, :class_name => "Detection", :conditions => "detections.abs_call = 'A'"
  has_many :absent_samples, :through => :absent_detections, :source => :sample

  has_many :marginal_detections, :class_name => "Detection", :conditions => "detections.abs_call = 'M'"
  has_many :marginal_samples, :through => :marginal_detections, :source => :sample

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "name",
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def generate_platform_hash(probesets)
      platform_hash = probesets.inject({}) do |h, probeset|
        h[probeset.id] = Platform.for_probeset(probeset.name)
        h
      end
    end
  end

  def ontology_term_hash(ncbo_id, status='P')
    ontology_terms = OntologyTerm.find(
      :all,
      :select => "ontology_terms.*, count(ontology_terms.id) AS found_count",
      :joins => "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id INNER JOIN samples ON annotations.geo_accession = samples.geo_accession INNER JOIN detections ON detections.sample_id = samples.id INNER JOIN probesets ON detections.probeset_id = probesets.id AND probesets.id = #{self.id} AND detections.abs_call = '#{status}' AND annotations.ncbo_id = '#{ncbo_id}' AND annotations.verified = 1",
      :group  => "ontology_terms.id",
      :order  => "ontology_terms.name"
    )

    ontology_terms.inject({}) do |h, term|
      h[term.term_id] = {:term => term, :found_count => term.found_count, :total_count => OntologyTerm.count_for_probeset(term.id, self.id, ncbo_id)}
      h
    end
  end

  def generate_term_array
    present_term_hash = ontology_term_hash("1000", 'P')
    absent_term_hash = ontology_term_hash("1000", 'A')
    marginal_term_hash = ontology_term_hash("1000", 'M')

    term_hash = {}
    present_term_hash.keys.each do |key|
      term_hash[key] = {:absent_count => 0, :marginal_count => 0, :present_count => present_term_hash[key][:found_count], :term => present_term_hash[key][:term], :total_count => present_term_hash[key][:total_count]}
    end

    absent_term_hash.keys.each do |key|
      if term_hash.has_key?(key)
        term_hash[key] = term_hash[key].merge!({:absent_count => absent_term_hash[key][:found_count]})
      else
        term_hash[key] = {:present_count => 0, :marginal_count => 0, :absent_count => absent_term_hash[key][:found_count], :term => absent_term_hash[key][:term], :total_count => absent_term_hash[key][:total_count]}
      end
    end

    marginal_term_hash.keys.each do |key|
      if term_hash.has_key?(key)
        term_hash[key] = term_hash[key].merge!({:marginal_count => marginal_term_hash[key][:found_count]})
      else
        term_hash[key] = {:present_count => 0, :absent_count => 0, :marginal_count => marginal_term_hash[key][:found_count], :term => marginal_term_hash[key][:term], :total_count => marginal_term_hash[key][:total_count]}
      end
    end
    term_hash.values.sort_by {|k| k[:total_count]}
  end

  def generate_gooogle_chart(a)
   g = Graph.new(a)
   g.generate
  end

  # we need to convert the forward slashes to back slashes and then encode them
  def to_param
    CGI::escape(self.name.gsub("/", "\\"))
  end

end
