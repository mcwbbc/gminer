class OntologyTerm < ActiveRecord::Base
  generator_for :term_id, :start => '1000|a' do |prev|
    id, term = prev.split('|')
    id.succ + '|' + term.succ
  end

  generator_for :ncbo_id, :start => 1000 do |prev|
    prev.succ
  end

  generator_for :name, :start => 'a' do |prev|
    prev.succ
  end
end
