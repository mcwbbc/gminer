class CreateOntologyTerms < ActiveRecord::Migration
  def self.up
    create_table :ontology_terms, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.string :term_id, :limit => 100
      t.string :ncbo_id, :limit => 100
      t.string :name, :limit => 255
      t.integer :annotations_count, :default => 0
    end

    add_index(:ontology_terms, :term_id)
    add_index(:ontology_terms, :ncbo_id)
    add_index(:ontology_terms, :ontology_id)

    add_foreign_key(:annotations, :ontology_terms, :dependent => :delete)
    add_foreign_key(:annotation_closures, :ontology_terms, :dependent => :delete)
    add_foreign_key(:results, :ontology_terms, :dependent => :delete)

  end

  def self.down
    remove_index(:ontology_terms, :term_id)
    remove_index(:ontology_terms, :ncbo_id)
    remove_index(:ontology_terms, :ontology_id)

    remove_foreign_key(:ontology_terms, :results)
    remove_foreign_key(:ontology_terms, :annotation_closures)
    remove_foreign_key(:ontology_terms, :annotations)

    drop_table :ontology_terms
  end
end
