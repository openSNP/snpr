class AddPhenotypeMailColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :message_on_new_phenotype, :boolean, default: false
    User.update_all ['message_on_new_phenotype = ?', false]
  end

  def self.down
    remove_column :users, :message_on_new_phenotype
  end
end
