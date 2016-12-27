# frozen_string_literal: true
class ChangeDescriptionFormatInPicturePhenotypes < ActiveRecord::Migration
  def change
    change_column :picture_phenotypes, :description, :text
  end
end
