class CreateWorkers < ActiveRecord::Migration
  def self.up
    create_table :workers, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :worker_key, :limit => 50
      t.boolean :ready, :default => false
      t.boolean :working, :default => false
    end

    add_index(:workers, :worker_key)
    add_index(:workers, :ready)
    add_index(:workers, :working)
  end

  def self.down
    remove_index(:workers, :worker_key)
    remove_index(:workers, :ready)
    remove_index(:workers, :working)

    drop_table :workers
  end
end
