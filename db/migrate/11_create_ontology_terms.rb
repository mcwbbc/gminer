class CreateOntologyTerms < ActiveRecord::Migration
  def self.up
    create_table :ontology_terms, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.string :term_id, :limit => 100
      t.string :ncbo_id, :limit => 100
      t.string :name, :limit => 255
      t.integer :annotations_count, :default => 0
      t.timestamps
    end

    add_index(:ontology_terms, :term_id)
    add_index(:ontology_terms, :ncbo_id)
    add_index(:ontology_terms, :ontology_id)

  end

  def self.down
    remove_index(:ontology_terms, :term_id)
    remove_index(:ontology_terms, :ncbo_id)
    remove_index(:ontology_terms, :ontology_id)

    drop_table :ontology_terms
  end
end
