class Processor
  include Messaging

  attr_accessor :worker_key, :server

  def initialize(server='localhost')
    Messaging.server(server)
  end

  class << self

    def save_term(params)
      databaser_message({'command' => 'saveterm'}.merge!(params).to_json)
    end

    def save_annotation(params)
      databaser_message({'command' => 'saveannotation'}.merge!(params).to_json)
    end

    def save_closure(params)
      databaser_message({'command' => 'saveclosure'}.merge!(params).to_json)
    end

    def databaser_message(msg)
      Messaging.publish("databaser-queue", msg)
    end

    def create_for(geo_accession, field_name, field_value, description, ncbo_id, current_ncbo_id, stopwords)
      cleaned = field_value.gsub(/[\r\n]+/, " ")
      hash = NCBOService.result_hash(cleaned, current_ncbo_id, stopwords)
      process_ncbo_results(hash, geo_accession, field_name, description, ncbo_id)
    end

    def process_ncbo_results(hash, geo_accession, field_name, description, ncbo_id)
      process_mgrep(hash["MGREP"], geo_accession, field_name, description, ncbo_id)
      process_closure(hash["ISA_CLOSURE"], geo_accession, field_name, ncbo_id)
    end

    def process_mgrep(hash, geo_accession, field_name, description, ncbo_id)
      if hash.keys.any?
        hash.keys.each do |key|
          current_ncbo_id, term_id = key.split("|")
          save_term('term_id' => "#{ncbo_id}|#{term_id}", 'ncbo_id' => ncbo_id, 'term_name' => hash[key][:name])
          save_annotation('geo_accession' => geo_accession, 'field_name' => field_name, 'ncbo_id' => ncbo_id, 'ontology_term_id' => "#{ncbo_id}|#{term_id}", 'text_start' => hash[key][:from], 'text_end' => hash[key][:to], 'description' => description)
        end
      else
        save_annotation('geo_accession' => geo_accession, 'field_name' => field_name, 'ncbo_id' => "none", 'ontology_term_id' => "none", 'text_start' => "0", 'text_end' => "0", 'description' => "")
      end
    end

    def process_closure(hash, geo_accession, field_name, ncbo_id)
      hash.keys.each do |key|
        hash[key].each do |closure|
          current_ncbo_id, term_id = closure[:id].split("|")
          key_current_ncbo_id, key_term_id = key.split("|")
          save_term('term_id' => "#{ncbo_id}|#{term_id}", 'ncbo_id' => ncbo_id, 'term_name' => closure[:name])
          save_closure('geo_accession' => geo_accession, 'field_name' => field_name, 'term_id' => "#{ncbo_id}|#{key_term_id}", 'closure_term' => "#{ncbo_id}|#{term_id}")
        end
      end
    end
  end

  def shutdown
    puts "Shutting down #{worker_key}"
    Messaging.publish('scheduler-queue', {'worker_key' => worker_key, 'command' => 'shutdown'}.to_json)
    AMQP.stop{ EM.stop }
    exit
  end

  def process_job(params)
    # params = {'job_id' => job.id, 'geo_accession' => job.geo_accession, 'field' => job.field, 'value' => item.send(job.field), 'description' => item.descriptive_text, 'ncbo_id' => ncbo_id, 'current_ncbo_id' => current_ncbo_id, 'stopwords' => stopwords}
    Processor.create_for(params['geo_accession'], params['field'], params['value'], params['description'], params['ncbo_id'], params['current_ncbo_id'], params['stopwords'])
    puts "processing #{worker_key} #{params['geo_accession']}:#{params['field']}"
    Messaging.publish('scheduler-queue', {'worker_key' => worker_key, 'command' => 'finished', 'job_id' => params['job_id']}.to_json)
  end

  def run
    Signal.trap('INT') { shutdown }
    Signal.trap('TERM'){ shutdown }

    @worker_key = UUIDTools::UUID.random_create.to_s

    Messaging.subscribe("worker-#{worker_key}") do |msg|
      message = JSON.parse(msg)
      case message['command']
        when 'prepare'
          Messaging.publish('scheduler-queue', {'worker_key' => worker_key, 'command' => 'ready'}.to_json)
        when 'job'
          Messaging.publish('scheduler-queue', {'worker_key' => worker_key, 'command' => 'working', 'job_id' => message['job_id']}.to_json)
          process_job(message)
        when 'shutdown'
          shutdown
      end
    end
    Messaging.publish('scheduler-queue', {'worker_key' => worker_key, 'command' => 'alive'}.to_json)
    puts "PID: #{worker_key}"
    Messaging.thread.join
  end
end