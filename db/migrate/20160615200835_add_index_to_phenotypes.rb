class AddIndexToPhenotypes < ActiveRecord::Migration
  def change
    add_index :phenotypes, :characteristic, :unique => true
  end
end
