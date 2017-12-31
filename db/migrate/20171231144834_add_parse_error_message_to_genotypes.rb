class AddParseErrorMessageToGenotypes < ActiveRecord::Migration
  def change
    add_column :genotypes, :parse_error_message, :string
  end
end
