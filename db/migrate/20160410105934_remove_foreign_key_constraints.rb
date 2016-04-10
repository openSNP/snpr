class RemoveForeignKeyConstraints < ActiveRecord::Migration
  def change
    remove_foreign_key :user_snps, :genotypes
    remove_foreign_key :genotypes, :users
    remove_foreign_key :fitbit_profiles, :users
    remove_foreign_key :homepages, :users
    remove_foreign_key :user_phenotypes, :users
    remove_foreign_key :user_picture_phenotypes, :users
    remove_foreign_key :phenotype_comments, :users
    remove_foreign_key :picture_phenotype_comments, :users
    remove_foreign_key :user_achievements, :users

    # don't do user_snps key again, takes forever
    add_foreign_key :genotypes, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :fitbit_profiles, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :homepages, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :user_phenotypes, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :user_picture_phenotypes, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :phenotype_comments, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :picture_phenotype_comments, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :user_achievements, :users, column: :user_id, on_delete: :cascade
  end
end
