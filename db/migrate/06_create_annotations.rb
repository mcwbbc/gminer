class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.integer :ontology_term_id
      t.integer :created_by_id, :default => 0
      t.integer :curated_by_id, :default => 0
      t.string :identifier
      t.string :geo_accession, :limit => 25
      t.string :field_name, :limit => 25
      t.string :ncbo_id, :limit => 100
      t.string :predicate
      t.string :description
      t.string :term_id
      t.string :term_name
      t.integer :from
      t.integer :to
      t.string :status, :limit => 20, :default => "unaudited"
      t.boolean :verified, :default => false
      t.boolean :mapping, :default => nil
      t.boolean :synonym, :default => nil
      t.timestamps
    end

    add_index(:annotations, :ontology_id)
    add_index(:annotations, :ontology_term_id)
    add_index(:annotations, :created_by_id)
    add_index(:annotations, :curated_by_id)
    add_index(:annotations, :geo_accession)
    add_index(:annotations, :field_name)
    add_index(:annotations, :ncbo_id)
    add_index(:annotations, :identifier)
    add_index(:annotations, :term_id)
    add_index(:annotations, :term_name)
    add_index(:annotations, :predicate)
    add_index(:annotations, :status)
    end

  def self.down
    drop_table :annotations
  end
end
