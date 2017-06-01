# frozen_string_literal: true
class AddNewsletterColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :message_on_newsletter, :boolean, default: true
    User.update_all ["message_on_newsletter = ?", true]
  end

  def self.down
    remove_column :users, :message_on_newsletter
  end
end