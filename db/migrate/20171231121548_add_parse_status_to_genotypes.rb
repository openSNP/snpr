# frozen_string_literal: true

class AddParseStatusToGenotypes < ActiveRecord::Migration
  def change
    add_column :genotypes, :parse_status, :string
  end
end
