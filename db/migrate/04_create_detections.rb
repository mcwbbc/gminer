class CreateDetections < ActiveRecord::Migration
  def self.up
    create_table :detections, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :sample_id
      t.integer :probeset_id
      t.string :abs_call, :limit => 2
    end

    add_index(:detections, :sample_id)
    add_index(:detections, :probeset_id)
    add_index(:detections, :abs_call)
  end

  def self.down
    remove_index(:detections, :sample_id)
    remove_index(:detections, :probeset_id)
    remove_index(:detections, :abs_call)

    drop_table :detections
  end
end
