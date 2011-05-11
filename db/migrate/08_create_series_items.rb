class CreateSeriesItems < ActiveRecord::Migration
  def self.up
    create_table :series_items, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :platform_id
      t.string :geo_accession, :limit => 25
      t.string :pubmed_id, :limit => 25
      t.string :title, :limit => 255
      t.text :summary
      t.text :overall_design
    end

    add_index(:series_items, :geo_accession)
    add_index(:series_items, :platform_id)
  end

  def self.down
    remove_index(:series_items, :geo_accession)
    remove_index(:series_items, :platform_id)
    drop_table :series_items
  end
end
