class CreateSnpComments < ActiveRecord::Migration
  def self.up
    create_table :snp_comments do |t|
      t.text :comment_text
      t.text :subject
      t.belongs_to :user
      t.belongs_to :snp
      t.timestamps
      t.integer :reply_to_id
    end
  end

  def self.down
    drop_table :snp_comments
  end
end
