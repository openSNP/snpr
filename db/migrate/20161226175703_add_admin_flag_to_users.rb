# frozen_string_literal: true
class AddAdminFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
