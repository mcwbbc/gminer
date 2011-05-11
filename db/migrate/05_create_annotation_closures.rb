class CreateAnnotationClosures < ActiveRecord::Migration
  def self.up
    create_table :annotation_closures, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :annotation_id
      t.integer :ontology_term_id
      t.string :identifier
      t.string :geo_accession, :limit => 25
      t.string :field_name, :limit => 25
      t.string :ncbo_id, :limit => 100
      t.string :term_id
      t.string :closure_term_id
      t.datetime :created_at
    end

    add_index(:annotation_closures, :annotation_id)
    add_index(:annotation_closures, :ontology_term_id)
    add_index(:annotation_closures, :term_id)
    add_index(:annotation_closures, :closure_term_id)
  end

  def self.down
    remove_index(:annotation_closures, :annotation_id)
    remove_index(:annotation_closures, :ontology_term_id)
    drop_table :annotation_closures
  end
end
