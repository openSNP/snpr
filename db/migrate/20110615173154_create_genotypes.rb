class CreateGenotypes < ActiveRecord::Migration
  def self.up
    create_table :genotypes do |t|
      t.datetime :uploadtime, null: false
      t.string :filetype, default: '23andme'
      t.string :originalfilename, null: false
      t.belongs_to :user, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :genotypes
  end
end
