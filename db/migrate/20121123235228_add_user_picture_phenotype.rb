class AddUserPicturePhenotype < ActiveRecord::Migration
  def self.up
    create_table :user_picture_phenotypes do |up|
      up.belongs_to :user
      up.belongs_to :picture_phenotype
      up.string :variation
      up.string :phenotype_picture_file_name
      up.string :phenotype_picture_content_type
      up.integer :phenotype_picture_file_size
      up.datetime :phenotype_picture_updated_at

      up.timestamps
    end
  end

  def self.down
    drop_table :user_picture_phenotypes
  end
end
