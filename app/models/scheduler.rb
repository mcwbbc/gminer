class Scheduler
  include Messaging

  attr_accessor :worker_max

  def watch_queue
    Messaging.subscribe("scheduler-queue") do |msg|
      ActiveRecord::Base.connection.reconnect!
      message = JSON.parse(msg)
      case message['command']
        when 'alive'
          create_worker(message['worker_key'])
        when 'ready'
          start_job(message['worker_key'])
        when 'working'
          started_job(message['worker_key'], message['job_id'])
        when 'finished'
          finished_job(message['worker_key'], message['job_id'])
        when 'shutdown'
          # do nothing, since rabbit will autokill the queue
          # Messaging.delete("worker-#{message['worker_key']}")
        when 'launch'
          launch_worker
      end # of case
    end # of subscribe
    launch_timer
    Messaging.thread.join
  end

  def create_worker(worker_key)
    w = Worker.create(:worker_key => worker_key, :working => false)
    Messaging.publish("worker-#{worker_key}", {'command' => 'prepare'}.to_json)
  end

  def send_job(worker_key, params)
    w = Worker.first(:conditions => {:worker_key => worker_key})
    w.update_attributes(:working => true)
    Messaging.publish("worker-#{worker_key}", params.merge!({'command' => 'job'}).to_json)
  end

  def start_job(worker_key)
    w = Worker.first(:conditions => {:worker_key => worker_key})
    w.update_attributes(:ready => true)
    if job = Job.available
      if a = Annotation.first(:conditions => {:geo_accession => job.geo_accession, :field => job.field})
        finished_job(worker_key, job.id)
      else
        job.update_attributes(:worker_key => worker_key, :started_at => Time.now)
        item = Job.load_item(job.geo_accession)
        stopwords = job.ontology.stopwords.blank? ? Constants::STOPWORDS : job.ontology.stopwords
        params = {'job_id' => job.id, 'geo_accession' => job.geo_accession, 'field' => job.field, 'value' => item.send(job.field), 'description' => item.descriptive_text, 'ncbo_id' => job.ontology.ncbo_id, 'current_ncbo_id' => job.ontology.current_ncbo_id, 'stopwords' => stopwords}
        send_job(worker_key, params)
      end
    else
      no_jobs(worker_key)
    end
  end

  def launch_timer
    puts "running launch timer"
    @timer = EM::PeriodicTimer.new(5) do 
      launched = launch_more
      @timer.cancel if !launched
    end
  end

  def launch_more
    worker_count = Worker.count
    puts "Workers: #{worker_count}"
    launch_it = (worker_count < worker_max && Job.available(:count => true) > 1)
    Messaging.publish("scheduler-queue", {'command' => 'launch'}.to_json) if launch_it
    launch_it
  end

  def no_jobs(worker_key)
    if Worker.count(:conditions => {:working => false}) > 1
      Messaging.publish("worker-#{worker_key}", {'command' => 'shutdown'}.to_json)
      w = Worker.first(:conditions => {:worker_key => worker_key})
      w.destroy
    else
      EM.add_timer(10){ Messaging.publish("worker-#{worker_key}", {'command' => 'prepare'}.to_json) } 
    end
  end

  def started_job(worker_key, job_id)
    job = Job.first(:conditions => {:id => job_id})
    job.update_attributes(:worker_key => worker_key, :started_at => Time.now)
  end

  def finished_job(worker_key, job_id)
    job = Job.first(:conditions => {:id => job_id})
    job.update_attributes(:finished_at => Time.now, :worker_key => nil)
    w = Worker.first(:conditions => {:worker_key => worker_key})
    w.update_attributes(:working => false)
    Messaging.publish("worker-#{worker_key}", {'command' => 'prepare'}.to_json)
  end

  def run(workers=5)
    @worker_max = workers.to_i
    job_count = Job.available(:count => true)
    worker_count = ((job_count*0.01).to_i)+1
    launch_databaser
#    Messaging.publish("scheduler-queue", {'command' => 'launch'}.to_json) if job_count > 1
#    clean_worker_queues
    watch_queue
  end

  def clean_worker_queues
    workers = Worker.all
  end

  def launch_worker
    puts "launching a worker!"
    # launch a worker
    pid = Process.fork do
      Process.fork do
        # normally you would redirect STDIN/STDOUT/STDERR here
        exec("cd #{Rails.root}/lib/launchers && ruby #{Rails.root}/lib/launchers/launch_processor.rb")
      end
      exit
    end
    Process.detach(pid)
  end

  def launch_databaser
    pid = Process.fork do
      Process.fork do
        exec("rake RAILS_ENV=#{Rails.env} distribute:databaser")
      end
      exit
    end
    Process.detach(pid)
  end

end