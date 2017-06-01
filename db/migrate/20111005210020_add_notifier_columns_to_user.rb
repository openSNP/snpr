# frozen_string_literal: true
class AddNotifierColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :message_on_message, :boolean, default: true
    add_column :users, :message_on_snp_comment_reply, :boolean, default: true
    add_column :users, :message_on_phenotype_comment_reply, :boolean, default: true
    User.update_all ["message_on_message = ?", false]
    User.update_all ["message_on_snp_comment_reply = ?", false]
    User.update_all ["message_on_phenotype_comment_reply = ?", false]
  end

  def self.down
    remove_column :users, :message_on_phenotype_comment_reply
    remove_column :users, :message_on_snp_comment_reply
    remove_column :users, :message_on_message
  end
end