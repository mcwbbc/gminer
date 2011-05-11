class CreateOntologies < ActiveRecord::Migration
  def self.up
    create_table :ontologies, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :ncbo_id, :limit => 100
      t.string :current_ncbo_id, :limit => 100
      t.string :name, :limit => 255
      t.string :version, :limit => 25
      t.text :stopwords
      t.text :expand_ontologies
      t.timestamps
    end

    add_index(:ontologies, :ncbo_id)
    add_index(:ontologies, :current_ncbo_id)

  end

  def self.down
    remove_index(:ontologies, :ncbo_id)
    remove_index(:ontologies, :current_ncbo_id)

    drop_table :ontologies
  end
end
