class Detection < ActiveRecord::Base
  extend Utilities::ClassMethods
  
  validates_uniqueness_of :id_ref, :scope => :sample_id
  validates_uniqueness_of :abs_call, :scope => [:sample_id, :id_ref]

  def present?
    self.abs_call == "P"
  end

end
