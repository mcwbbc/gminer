class CreatePlatforms < ActiveRecord::Migration
  def self.up
    create_table :platforms, :options => 'ENGINE=InnoDB default charset=utf8' do |t|
      t.string :geo_accession, :limit => 25
      t.string :title, :limit => 255
      t.string :organism, :limit => 255
    end

    add_index(:platforms, :geo_accession)

    add_foreign_key(:datasets, :platforms, :dependent => :delete)
    add_foreign_key(:samples, :platforms, :dependent => :delete)
    add_foreign_key(:series_items, :platforms, :dependent => :delete)
  end

  def self.down
    remove_foreign_key(:platforms, :series_items)
    remove_foreign_key(:platforms, :samples)
    remove_foreign_key(:platforms, :datasets)

    drop_table :platforms
  end
end
