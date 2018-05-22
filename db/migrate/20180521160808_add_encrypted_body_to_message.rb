class AddEncryptedBodyToMessage < ActiveRecord::Migration
  def up
    add_column :messages, :encrypted_body, :text
    add_column :messages, :encrypted_body_iv, :string
    add_column :messages, :encrypted_subject, :text
    add_column :messages, :encrypted_subject_iv, :string
    Message.reset_column_information
    Message.find_each do |message|
      # Read `body` and write to `encrypted_body`.
      message.update!(body: message.read_attribute(:body))
      message.update!(subject: message.read_attribute(:subject))
    end
  end

  def down
    remove_column :messages, :encrypted_body, :text
    remove_column :messages, :encrypted_body_iv, :string
    remove_column :messages, :encrypted_subject, :text
    remove_column :messages, :encrypted_subject_iv, :string
  end
end
