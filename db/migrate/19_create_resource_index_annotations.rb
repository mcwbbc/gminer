class CreateResourceIndexAnnotations < ActiveRecord::Migration
  def self.up
    create_table :resource_index_annotations, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :identifier
      t.string :geo_accession, :limit => 25
      t.string :field_name, :limit => 25
      t.string :ncbo_id, :limit => 100
      t.string :term_id
      t.integer :from
      t.integer :to
    end

    add_index(:resource_index_annotations, :identifier, :unique => true)
    add_index(:resource_index_annotations, :geo_accession)
    add_index(:resource_index_annotations, :field_name)
    add_index(:resource_index_annotations, :ncbo_id)
    add_index(:resource_index_annotations, :term_id)
    end

  def self.down
    drop_table :resource_index_annotations
  end
end
