class ComparisonReport

  class << self
    def results(comparison_date)
      Constants::ONTOLOGIES.keys.inject({}) do |hash, ncbo_id|
        hash[ncbo_id] = {}
        field_names = [Comparison.field_names_for_ontology(ncbo_id, comparison_date)+Annotation.field_names_for_ontology(ncbo_id)].flatten.uniq
        field_names.each do |field_name|
          hash[ncbo_id][field_name] = self.get_counts(ncbo_id, field_name, comparison_date)
        end
        hash
      end
    end

    def get_count(sql)
      Annotation.count_by_sql(sql)
    end

    def valid_count(comparison_date, ontology_sql, field_name)
      # seen - valid
      sql = "SELECT COUNT(DISTINCT annotations.identifier) FROM annotations INNER JOIN comparisons ON comparisons.identifier = annotations.identifier WHERE annotations.verified = 1 AND annotations.status = 'audited' AND annotations.created_by_id = 0 AND annotations.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql}"
      seen_valid = get_count(sql)

      sql = "SELECT COUNT(DISTINCT id) FROM annotations WHERE verified = 1 AND status = 'audited' AND created_by_id = 0 AND annotations.field_name = '#{field_name}' #{ontology_sql}"
      valid_previous = get_count(sql)
      [seen_valid, valid_previous]
    end

    def invalid_count(comparison_date, ontology_sql, field_name)
      # seen - invalid
      sql = "SELECT COUNT(DISTINCT annotations.identifier) FROM annotations INNER JOIN comparisons ON comparisons.identifier = annotations.identifier WHERE annotations.verified = 0 AND annotations.status = 'audited' AND annotations.created_by_id = 0 AND annotations.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql}"
      seen_invalid = get_count(sql)

      sql = "SELECT COUNT(DISTINCT id) FROM annotations WHERE verified = 0 AND status = 'audited' AND created_by_id = 0 AND annotations.field_name = '#{field_name}' #{ontology_sql}"
      invalid_previous = get_count(sql)
      [seen_invalid, invalid_previous]
    end

    def manual_count(comparison_date, ontology_sql, field_name)
      # seen - manual
      sql = "SELECT COUNT(DISTINCT annotations.identifier) FROM annotations INNER JOIN comparisons ON comparisons.identifier = annotations.identifier WHERE annotations.created_by_id > 0 AND annotations.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql}"
      seen_manual = get_count(sql)

      sql = "SELECT COUNT(DISTINCT id) FROM annotations WHERE verified = 1 AND status = 'audited' AND created_by_id > 0 AND annotations.field_name = '#{field_name}' #{ontology_sql}"
      manual_previous = get_count(sql)
      [seen_manual, manual_previous]
    end

    def unaudited_count(comparison_date, ontology_sql, field_name)
      # seen - unaudited
      sql = "SELECT COUNT(DISTINCT comparisons.identifier) FROM annotations INNER JOIN comparisons ON comparisons.identifier = annotations.identifier WHERE annotations.status = 'unaudited' AND annotations.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql}"
      seen_unaudited = get_count(sql)

      sql = "SELECT COUNT(DISTINCT id) FROM annotations WHERE status = 'unaudited' AND annotations.field_name = '#{field_name}' #{ontology_sql}"
      unaudited_previous = get_count(sql)
      [seen_unaudited, unaudited_previous]
    end

    def not_seen_count(comparison_date, ontology_sql, field_name)
      # not seen
      sql = "SELECT (SELECT count(*) FROM comparisons WHERE comparisons.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql}) - (SELECT count(comparisons.id) FROM comparisons INNER JOIN annotations ON comparisons.identifier = annotations.identifier WHERE annotations.field_name = '#{field_name}' AND comparisons.archived_at = '#{comparison_date}' #{ontology_sql})"
      not_seen = get_count(sql)
    end

    def get_ontology_sql(table, ncbo_id)
      if (ncbo_id == "all")
        ontology_sql = ""
      else
        ontology_sql = "AND #{table}.ncbo_id = #{ncbo_id}"
      end
      ontology_sql
    end

    def get_counts(ncbo_id, field_name, comparison_date)
      ontology_sql = get_ontology_sql('annotations', ncbo_id)
      seen_valid, valid_previous = valid_count(comparison_date, ontology_sql, field_name)
      seen_invalid, invalid_previous = invalid_count(comparison_date, ontology_sql, field_name)
      seen_manual, manual_previous = manual_count(comparison_date, ontology_sql, field_name)
      seen_unaudited, unaudited_previous = unaudited_count(comparison_date, ontology_sql, field_name)

      # previous_total
      sql = "SELECT COUNT(DISTINCT id) FROM annotations WHERE annotations.field_name = '#{field_name}' #{ontology_sql}"
      previous_total = get_count(sql)

      # current_total
      ontology_sql = get_ontology_sql('comparisons', ncbo_id)
      not_seen = not_seen_count(comparison_date, ontology_sql, field_name)

      sql = "SELECT COUNT(DISTINCT identifier) FROM comparisons WHERE comparisons.field_name = '#{field_name}' AND created_at = '#{comparison_date}' #{ontology_sql}"
      current_total = get_count(sql)

      if current_total > 0
        seen_valid_percent = ('%.2f' % ((seen_valid.to_f/current_total.to_f)*100)).to_f
        seen_invalid_percent = ('%.2f' % ((seen_invalid.to_f/current_total.to_f)*100)).to_f
        seen_manual_percent = ('%.2f' % ((seen_manual.to_f/current_total.to_f)*100)).to_f
        seen_unaudited_percent = ('%.2f' % ((seen_unaudited.to_f/current_total.to_f)*100)).to_f
        not_seen_percent = ('%.2f' % ((not_seen.to_f/current_total.to_f)*100)).to_f

        array = []
        array << ['Seen - Valid', seen_valid_percent]
        array << ['Seen - Invalid', seen_invalid_percent]
        array << ['Seen - Manual', seen_manual_percent]
        array << ['Seen - Unaudited', seen_unaudited_percent]
        array << ['Not Seen', not_seen_percent]
        chart = PieChart.new(array, {:title => "#{Constants::ONTOLOGIES[ncbo_id][:name]} #{field_name} ratios"})
      else
        chart = ""
      end

      hash = {
        'seen_valid' => seen_valid,
        'valid_previous' => valid_previous,
        'seen_invalid' => seen_invalid,
        'invalid_previous' => invalid_previous,
        'seen_manual' => seen_manual,
        'manual_previous' => manual_previous,
        'seen_unaudited' => seen_unaudited,
        'unaudited_previous' => unaudited_previous,
        'not_seen' => not_seen,
        'previous_total' => previous_total,
        'current_total' => current_total,
        'chart' => chart
        }
    end

  end

end