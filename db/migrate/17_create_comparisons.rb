class CreateComparisons < ActiveRecord::Migration
  def self.up
    create_table :comparisons, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.integer :ontology_id
      t.integer :ontology_term_id
      t.integer :created_by_id, :default => 0
      t.integer :curated_by_id, :default => 0
      t.string :identifier
      t.string :geo_accession, :limit => 25
      t.string :field_name, :limit => 25
      t.string :ncbo_id, :limit => 100
      t.string :description, :limit => 255
      t.integer :from
      t.integer :to
      t.string :status, :limit => 20, :default => "unaudited"
      t.boolean :verified, :default => false
      t.boolean :mapping, :default => nil
      t.boolean :synonym, :default => nil
      t.timestamps
      t.datetime :archived_at, :default => nil
    end

    add_index(:comparisons, :ontology_id)
    add_index(:comparisons, :ontology_term_id)
    add_index(:comparisons, :geo_accession)
    add_index(:comparisons, :field_name)
    add_index(:comparisons, :ncbo_id)
    add_index(:comparisons, :identifier)
    add_index(:comparisons, :status)
    add_index(:comparisons, :archived_at)
    end

  def self.down
    drop_table :comparisons
  end
end
