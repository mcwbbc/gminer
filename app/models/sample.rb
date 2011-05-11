class Sample < ActiveRecord::Base
  include Abstract::Sample
  include Utilities
  extend Utilities::ClassMethods

  acts_as_taggable_on :tags

  belongs_to :series_item
  belongs_to :platform, :class_name => "Gminer::Platform"
  has_many :detections, :dependent => :delete_all
  has_many :annotations, :dependent => :delete_all, :foreign_key => :geo_accession, :primary_key => :geo_accession

  class << self

    def load_sample
      @sample ||= begin
        if RedisConnection.db.exists('sample-geo-accessions')
          RedisConnection.db.smembers('sample-geo-accessions').sort
        else
          Sample.all.map { |item| item.geo_accession }.each do |id|
            RedisConnection.db.sadd('sample-geo-accessions', id)
          end
        end
      end
    end

    def for_probeset(ontology_term_id, probeset_id, status)
      joins = "INNER JOIN annotations ON samples.geo_accession = annotations.geo_accession INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id INNER JOIN detections ON detections.sample_id = samples.id INNER JOIN probesets ON detections.probeset_id = probesets.id"
      find(:all,
        :select => 'samples.geo_accession',
        :joins => joins,
        :conditions => ["probesets.name = ? AND detections.abs_call = ? AND ontology_terms.term_id = ? AND annotations.verified = 1", probeset_id, status, ontology_term_id],
        :group => "samples.geo_accession"
      )
    end

    def count_for_probeset(probeset_id, ontology_term_id)
      count('samples.id',
        :distinct => true,
        :joins => "INNER JOIN annotations ON samples.geo_accession = annotations.geo_accession INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id INNER JOIN detections ON detections.sample_id = samples.id INNER JOIN probesets ON detections.probeset_id = probesets.id",
        :conditions => ["probesets.id = ? AND ontology_terms.id = ? AND annotations.verified = 1", probeset_id, ontology_term_id]
      )
    end

    def matching(options)
      sql = "SELECT samples.id, samples.geo_accession, series_items.pubmed_id as pubmed_id, ontology_terms.id as ontology_term_id FROM samples, ontology_terms, series_items, annotations, ontologies "
      sql << "WHERE ontologies.ncbo_id = #{options[:ncbo_id]} "
      sql << "AND ontology_terms.term_id = '#{options[:term_id]}' " if options[:term_id]
      sql << "AND ontology_terms.ncbo_id = ontologies.ncbo_id "
      sql << "AND annotations.field_name = '#{options[:field_name]}' "
      sql << "AND series_items.pubmed_id != '' " if options[:require_pubmed_id]
      sql << "AND samples.series_item_id = series_items.id "
      sql << "AND annotations.ontology_term_id = ontology_terms.id "
      sql << "AND annotations.geo_accession = samples.geo_accession"
      samples = Sample.find_by_sql(sql)
    end

    def create_results(passed = {})
      options = {:ncbo_id => 1000, :field_name => "source_name", :require_pubmed_id => false}.merge!(passed)
      Sample.matching(options).each do |sample|
        inserts = []
        earlier = Time.new
        Detection.all(:conditions => {:sample_id => sample.id, :abs_call => 'P'}).each do |detection|
          inserts.push "('#{sample.id}', '#{detection.probeset_id}', '#{sample.pubmed_id}', '#{sample.ontology_term_id}')"
        end

        if inserts.any?
          sql = "INSERT INTO results (sample_id, probeset_id, pubmed_id, ontology_term_id) VALUES #{inserts.join(", ")}"
          begin
            ActiveRecord::Base.connection.execute(sql)
            puts "Sample #{sample.geo_accession} took #{Time.new-earlier}" if options[:debug]
          rescue ActiveRecord::StatementInvalid => e
            if e.message =~ /Mysql::Error: Duplicate entry/
              puts "Mysql::Error: Duplicate entry #{sample.geo_accession} #{sample.ontology_term_id}"
            else
              raise e
            end
          end
        else
          puts "Sample #{sample.geo_accession} had no inserts" if options[:debug]
        end
      end
    end
  end

  def create_detections(probeset_id_hash)
    data_regex = /^.+_at/
    abs_call_regex = /^#ABS_CALL/
    header_regex = /^ID_REF/
    start_table_regex = /^!sample_table_begin/
    end_table_regex = /^!sample_table_end/

    inserts = []
    abs_call_flag = false
    intable_flag = false
    id_ref_header_pos = nil
    abs_call_header_pos = nil
    mass_header_pos = nil
    significance_header_pos = nil

    File.open(local_sample_filename, "rb", :encoding => 'ISO-8859-1').each do |line|
      if !abs_call_flag
        abs_call_flag = line.match(abs_call_regex)
        next
      end

      if line.match(header_regex)
        headers = line.chomp.split("\t")
        id_ref_header_pos = headers.index("ID_REF")
        abs_call_header_pos = headers.index("ABS_CALL")
        abs_call_flag = (headers.include?("ID_REF") && headers.include?("ABS_CALL"))
      end

      if line.match(end_table_regex)
        intable_flag = false
      end

      if intable_flag
        if line.match(data_regex)
          data = line.chomp.split("\t")
          if (data[id_ref_header_pos] && data[abs_call_header_pos])

            id_ref = data[id_ref_header_pos].chomp
            if !probeset_id_hash[id_ref]
              if !p = Probeset.first(:conditions => {:name => id_ref})
                p = Probeset.create(:name => id_ref)
              end
              probeset_id_hash[id_ref] = p.id
            end
            inserts.push "('#{self.id}', '#{probeset_id_hash[id_ref]}', '#{data[abs_call_header_pos].chomp}')"
          end
        end
      end

      if line.match(start_table_regex)
        intable_flag = true
      end
    end

    if inserts.any?
      sql = "INSERT INTO detections (sample_id, probeset_id, abs_call) VALUES #{inserts.join(", ")}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

end
