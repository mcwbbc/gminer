class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :platform_id
      t.string :geo_accession, :limit => 25
      t.string :reference_series, :limit => 25
      t.string :pubmed_id, :limit => 25
      t.string :organism, :limit => 255
      t.text :title
      t.text :description
      t.datetime :annotating_at
      t.datetime :annotated_at
    end

    add_index(:datasets, :geo_accession)
    add_index(:datasets, :platform_id)
  end

  def self.down
    remove_index(:datasets, :geo_accession)
    remove_index(:datasets, :platform_id)
    drop_table :datasets
  end
end
