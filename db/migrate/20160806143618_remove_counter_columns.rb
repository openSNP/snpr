class RemoveCounterColumns < ActiveRecord::Migration
  def change
    remove_column :phenotypes, :number_of_users
    remove_column :users, :phenotype_additional_counter
  end
end
