class ProgressReport

  class << self
    def results
      hash = {}
      Constants::GEO_TYPES.each do |geo_type|
        hash[geo_type] = self.get_counts(geo_type)
      end
      hash
    end

    def get_counts(geo_type)
      total = Annotation.count(:conditions => ['geo_accession LIKE ?', "#{Constants::MODEL_GEO_PREFIXES[geo_type]}%"])
      unaudited = Annotation.count(:conditions => ["status = 'unaudited' AND geo_accession LIKE ?", "#{Constants::MODEL_GEO_PREFIXES[geo_type]}%"])
      verified = Annotation.count(:conditions => ["verified = 1 AND status = 'audited' AND geo_accession LIKE ?", "#{Constants::MODEL_GEO_PREFIXES[geo_type]}%"])
      unverified = Annotation.count(:conditions => ["verified = 0 AND status = 'audited' AND geo_accession LIKE ?", "#{Constants::MODEL_GEO_PREFIXES[geo_type]}%"])
      annotated = verified+unverified
      manual = Annotation.count(:conditions => ['created_by_id != 0 AND geo_accession LIKE ?', "#{Constants::MODEL_GEO_PREFIXES[geo_type]}%"])

      if total > 0
        annotated_percent = "#{'%.2f' % ((annotated.to_f/total.to_f)*100)}%"
        verified_percent = ('%.2f' % ((verified.to_f/total.to_f)*100)).to_f
        unverified_percent = ('%.2f' % ((unverified.to_f/total.to_f)*100)).to_f
        unaudited_percent = ('%.2f' % ((unaudited.to_f/total.to_f)*100)).to_f
        array = []
        array << ['Valid', verified_percent]
        array << ['Invalid', unverified_percent]
        array << ['Unaudited', unaudited_percent]
        chart = PieChart.new(array, {:title => geo_type})
      else
        annotated_percent = "n/a"
        chart = ""
      end

      hash = {
        'total' => total,
        'unaudited' => unaudited,
        'verified' => verified,
        'unverified' => unverified,
        'annotated' => annotated,
        'manual' => manual,
        'percent' => annotated_percent,
        'chart' => chart
        }
    end

  end

end