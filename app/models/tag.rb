class Tag < ActiveRecord::Base

  attr_accessible :description

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => :name,
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def top_tags(tags=[], limit=10)
      tag_list = "'"
      tag_list << tags.join("','")
      tag_list << "'"

      find(:all,
          :select => 'tags.id, name, description, count(tag_id) AS count',
          :conditions => "name NOT IN (#{tag_list})",
          :group => :id,
          :limit => limit,
          :order => 'count DESC, name',
          :joins => 'LEFT JOIN taggings ON taggings.tag_id = tags.id')

    end

    def all_tags(tags=[])
      tag_list = "'"
      tag_list << tags.join("','")
      tag_list << "'"

      tags = find(:all,
          :select => :name,
          :conditions => "name NOT IN (#{tag_list})",
          :order => :name)
    end


    def process_tagging(action, geo_accession, tag_list)
      item = Tag.load_item(geo_accession)
      if (item.is_a?(SeriesItem))
        process_children(action, item, tag_list)
        process_item(action, item, tag_list)
      else
        process_item(action, item, tag_list)
      end
      item
    end

    def process_children(action, item, tag_list)
      item.samples.each do |sample|
        process_item(action, sample, tag_list)
      end
    end

    def process_item(action, item, tag_list)
      if (action == "create")
        item.tag_list.add(tag_list, :parse => true)
      elsif (action == "delete")
        item.tag_list.remove(tag_list, :parse => true)
      end
      item.save
      item.reload
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

  end

end