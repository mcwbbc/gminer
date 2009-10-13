class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.integer :ontology_term_id
      t.string :geo_accession, :limit => 25
      t.string :field, :limit => 25
      t.string :ncbo_id, :limit => 100
      t.string :description, :limit => 255
      t.integer :from
      t.integer :to
      t.boolean :verified, :default => false
      t.boolean :audited, :default => false 
    end

    add_index(:annotations, :ontology_id)
    add_index(:annotations, :ontology_term_id)
    add_index(:annotations, :geo_accession)
    add_index(:annotations, :field)
    add_index(:annotations, :ncbo_id)
    add_foreign_key(:annotation_closures, :annotations, :dependent => :delete)
    end

  def self.down
    remove_foreign_key(:annotations, :annotation_closures)
    remove_index(:annotations, :ontology_term_id)
    remove_index(:annotations, :geo_accession)
    remove_index(:annotations, :field)
    remove_index(:annotations, :ncbo_id)
    remove_index(:annotations, :ontology_id)

    drop_table :annotations
  end
end
