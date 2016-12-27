# frozen_string_literal: true
class CreatePgpAnnotations < ActiveRecord::Migration
  def self.up
    create_table :pgp_annotations do |t|
      t.text :gene
      t.text :qualified_impact
      t.text :inheritance
      t.text :summary
      t.text :trait
      t.timestamps 
      t.belongs_to :snp
    end
  end
  
  def self.down
    drop_table :pgp_annotations
  end
end