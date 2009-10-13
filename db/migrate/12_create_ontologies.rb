class CreateOntologies < ActiveRecord::Migration
  def self.up
    create_table :ontologies, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :ncbo_id, :limit => 100
      t.string :current_ncbo_id, :limit => 100
      t.string :name, :limit => 255
      t.string :version, :limit => 25
      t.text :stopwords
      t.timestamps
    end

    add_index(:ontologies, :ncbo_id)
    add_index(:ontologies, :current_ncbo_id)

    add_foreign_key(:ontology_terms, :ontologies, :dependent => :delete)
    add_foreign_key(:annotations, :ontologies, :dependent => :delete)
  end

  def self.down
    remove_index(:ontologies, :ncbo_id)
    remove_index(:ontologies, :current_ncbo_id)

    remove_foreign_key(:ontologies, :ontology_terms)
    remove_foreign_key(:ontologies, :annotations)

    drop_table :ontologies
  end
end
