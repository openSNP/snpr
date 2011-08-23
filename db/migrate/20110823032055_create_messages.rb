class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :subject
	  t.integer :user_id
      t.text :body
      t.boolean :sent
	  t.integer :from_id
	  t.integer :to_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
