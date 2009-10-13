class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :sample_id
      t.integer :ontology_term_id
      t.string :id_ref, :limit => 100
      t.string :pubmed_id, :limit => 25
    end

    add_index(:results, :sample_id)
    add_index(:results, :id_ref)
    add_index(:results, :ontology_term_id)
  end

  def self.down
    remove_index(:results, :sample_id)
    remove_index(:results, :id_ref)
    remove_index(:results, :ontology_term_id)

    drop_table :results
  end
end
