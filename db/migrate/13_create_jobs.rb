class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.string :worker_key, :limit => 50
      t.string :geo_accession, :limit => 25
      t.string :field, :limit => 50
      t.datetime :created_at
      t.double :started_at
      t.double :working_at
      t.double :finished_at
    end

    add_index(:jobs, :worker_key)
    add_index(:jobs, :geo_accession)
    add_index(:jobs, :ontology_id)
  end

  def self.down
    remove_index(:jobs, :ontology_id)
    remove_index(:jobs, :geo_accession)
    remove_index(:jobs, :worker_key)

    drop_table :jobs
  end
end
