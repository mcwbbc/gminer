#require 'redis'
#include Mongo

class Databaser
  include Messaging

  def watch_queue
    Messaging.subscribe("databaser-queue") do |msg|
      message = JSON.parse(msg)
      case message['command']
        when 'saveterm'
          OntologyTerm.persist(message['term_id'], message['ncbo_id'], message['term_name'])
#          @terms << {'term_id' => message['term_id'], 'ncbo_id' => message['ncbo_id'], 'term_name' => message['term_name']}
#          key = message['term_id']
#          if !ot = @r[key]
#            @r[key] = {'term_id' => message['term_id'], 'ncbo_id' => message['ncbo_id'], 'term_name' => message['term_name']}.to_json
#            @r["#{key}-count"] = 0
#          end
        when 'saveannotation'
          Annotation.persist(message['geo_accession'], message['field_name'], message['ncbo_id'], message['ontology_term_id'], message['text_start'], message['text_end'], message['description'])
#          @annotations << {'geo_accession' => message['geo_accession'], 'field_name' => message['field_name'], 'ncbo_id' => message['ncbo_id'], 'ontology_term_id' => message['ontology_term_id'], 'text_start' => message['text_start'], 'text_end' => message['text_end'], 'description' => message['description'], 'closures' => []}
#          counter_key = "#{message['ontology_term_id']}-counter"
#          key = "#{message['ontology_term_id']}:#{message['geo_accession']}:#{message['field_name']}"
#          if !a = @r[key]
#            @r[key] = {'geo_accession' => message['geo_accession'], 'field_name' => message['field_name'], 'ncbo_id' => message['ncbo_id'], 'ontology_term_id' => message['ontology_term_id'], 'text_start' => message['text_start'], 'text_end' => message['text_end'], 'description' => message['description']}.to_json
#            @r.incr(counter_key)
#          end
        when 'saveclosure'
          AnnotationClosure.persist(message['geo_accession'], message['field_name'], message['term_id'], message['closure_term'])
#          if annotation = @annotations.find_one('geo_accession' => message['geo_accession'], 'field_name' => message['field_name'], 'ontology_term_id' => message['term_id'])
#            annotation["closures"] << {'closure_term' => message['closure_term']}
#          end
#          key = "#{message['geo_accession']}:#{message['field_name']}:#{message['term_id']}"
#          if !ac = @r[key]
#            @r[key] = {'geo_accession' => message['geo_accession'], 'field_name' => message['field_name'], 'term_id' => message['term_id'], 'closure_term' => message['closure_term']}.to_json
#          end
      end
    end
    Messaging.thread.join
  end

  def run
#    @r = Redis.new
#    @db = Connection.new.db('gminer')
#    @terms = @db.collection('terms')
#    @annotations = @db.collection('annotations')
#    @annotation_closures = @db.collection('annotation_closures')
    ActiveRecord::Base.connection.reconnect!
    watch_queue
  end

end
