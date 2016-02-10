class AddForeignKeyConstraints < ActiveRecord::Migration
  def up
    add_foreign_key :user_snps, :genotypes, column: :genotype_id # primary_key: defaults to :id so no need to add
    add_foreign_key :genotypes, :users, column: :user_id
    add_foreign_key :fitbit_profiles, :users, column: :user_id
    add_foreign_key :homepages, :users, column: :user_id
    add_foreign_key :user_phenotypes, :users, column: :user_id
    add_foreign_key :user_picture_phenotypes, :users, column: :user_id
    add_foreign_key :phenotype_comments, :users, column: :user_id
    add_foreign_key :picture_phenotype_comments, :users, column: :user_id
    add_foreign_key :user_achievements, :users, column: :user_id
  end

  def down
    remove_foreign_key :user_snps, :genotypes
    remove_foreign_key :genotypes, :users
    remove_foreign_key :fitbit_profiles, :users
    remove_foreign_key :homepages, :users
    remove_foreign_key :user_phenotypes, :users
    remove_foreign_key :user_picture_phenotypes, :users
    remove_foreign_key :phenotype_comments, :users
    remove_foreign_key :picture_phenotype_comments, :users
    remove_foreign_key :user_achievements, :users
  end
end
