class Detection < ActiveRecord::Base
  extend Utilities::ClassMethods

  validates_uniqueness_of :probeset_id, :scope => :sample_id
  validates_uniqueness_of :abs_call, :scope => [:sample_id, :probeset_id]

  belongs_to :sample
  belongs_to :probeset

  named_scope :present, :conditions => {:abs_call => 'P'}
  named_scope :absent, :conditions => {:abs_call => 'A'}
  named_scope :marginal, :conditions => {:abs_call => 'M'}

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "probesets.name",
               :conditions => conditions,
               :joins => [:sample, :probeset],
               :page => page,
               :per_page => size
               )
    end
  end


  def present?
    self.abs_call == "P"
  end

end
