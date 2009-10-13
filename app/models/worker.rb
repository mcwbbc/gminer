class Worker < ActiveRecord::Base

  class << self
    def available(*hash)
      hash = hash.any? ? hash.first : {}
      options = {}.merge!(hash)
      if options[:count]
        count(:conditions => {:working => false, :ready => true})
      else
        first(:conditions => {:working => false, :ready => true})
      end
    end
  end

end