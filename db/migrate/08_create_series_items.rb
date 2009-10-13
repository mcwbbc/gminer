class CreateSeriesItems < ActiveRecord::Migration
  def self.up
    create_table :series_items, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :platform_id
      t.string :geo_accession, :limit => 25
      t.string :pubmed_id, :limit => 25
      t.string :title, :limit => 255
      t.text :summary
      t.text :overall_design
      t.datetime :annotating_at
      t.datetime :annotated_at
    end

    add_index(:series_items, :geo_accession)
    add_index(:series_items, :platform_id)

    add_foreign_key(:samples, :series_items, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:series_items, :samples)

    remove_index(:series_items, :geo_accession)
    remove_index(:series_items, :platform_id)
    drop_table :series_items
  end
end
