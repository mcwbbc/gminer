class Comparison < ActiveRecord::Base

  class << self

    def get_field_name_hash(date)
      Constants::ONTOLOGIES.keys.inject({}) do |hash, ncbo_id|
        hash[ncbo_id] = Comparison.field_names_for_ontology(ncbo_id, date)
        hash
      end
    end

    def field_names_for_ontology(ncbo_id, date)
      if ncbo_id == "all"
        find(:all, :select => 'field_name', :group => 'field_name', :conditions => {:archived_at => date}).map(&:field_name)
      else
        find(:all, :select => 'field_name, ncbo_id', :group => 'field_name', :conditions => {:ncbo_id => ncbo_id, :archived_at => date}).map(&:field_name)
      end
    end

    def get_newest_date
      maximum(:archived_at).strftime("%Y-%m-%d %H:%M:%S %Z")
    end

    def get_all_dates
      find(:all, :select => 'archived_at', :group => "archived_at", :order => "archived_at DESC")
    end

  end

end