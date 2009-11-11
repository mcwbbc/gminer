class CreateProbesets < ActiveRecord::Migration
  def self.up
    create_table :probesets, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :name, :limit => 100
    end

    add_index(:probesets, :name, :unique => true )
  end

  def self.down
    drop_table :probesets
  end
end
