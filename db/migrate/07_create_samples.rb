class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :series_item_id
      t.integer :platform_id
      t.string :geo_accession, :limit => 25
      t.string :sample_type, :limit => 255
      t.string :source_name, :limit => 255
      t.string :organism, :limit => 255
      t.string :label, :limit => 255
      t.string :molecule, :limit => 255
      t.text :title
      t.text :characteristics
      t.text :treatment_protocol
      t.text :extract_protocol
      t.text :label_protocol
      t.text :scan_protocol
      t.text :hyp_protocol
      t.text :description
      t.text :data_processing
    end

    add_index(:samples, :geo_accession)
    add_index(:samples, :series_item_id)
    add_index(:samples, :platform_id)

    add_foreign_key(:detections, :samples, :dependent => :delete)
    add_foreign_key(:results, :samples, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:samples, :results)
    remove_foreign_key(:samples, :detections)

    remove_index(:samples, :geo_accession)
    remove_index(:samples, :series_item_id)
    remove_index(:samples, :platform_id)
    drop_table :samples
  end
end
