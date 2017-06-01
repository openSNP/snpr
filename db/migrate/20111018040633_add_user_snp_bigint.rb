# frozen_string_literal: true
class AddUserSnpBigint < ActiveRecord::Migration
  def self.up
		change_column :user_snps, :id, :integer, limit: 8
  end

  def self.down
		change_column :user_snps, :id, :integer
  end
end
