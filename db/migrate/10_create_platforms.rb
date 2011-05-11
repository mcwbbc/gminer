class CreatePlatforms < ActiveRecord::Migration
  def self.up
    create_table :platforms, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :geo_accession, :limit => 25
      t.string :title, :limit => 255
      t.string :organism, :limit => 255
    end

    add_index(:platforms, :geo_accession)

  end

  def self.down
    drop_table :platforms
  end
end
