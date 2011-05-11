class RatmineService
  include HTTParty
    base_uri 'ratmine.mcw.edu'
    format :xml

  class << self

    def get_data(term_id)
      parameters = {
        "name" => 'rs_to_all_parents',
        "constraint1" => 'RSTerm',
        "op1" => "LOOKUP",
        "value1" => term_id,
        "size" => "100",
        "format" => "xml"
      }

      begin
        data = RatmineService.get("/ratmine/service/template/results", :query => parameters)
      rescue Exception => e
        Rails.logger.debug("#{e.inspect} -- #{e.message}")
      end
    end

    def parent_array(term_id)
      result = RatmineService.get_data(term_id)
      result_array = result['ResultSet']['Result']
      if result_array.many?
        result_array.inject([]) do |a, member|
          id = member['i'][3]
          a << id if id != term_id
          a
        end-["RS:0000457", "RS:0000765"] # remove 'rat strain', 'inbred strain'
      else
        []
      end
    end

  end # of class << self

end