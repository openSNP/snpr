# frozen_string_literal: true
class TrulyAddRevisionToSnpediaPaper < ActiveRecord::Migration
  def self.up
      if column_exists? :snpedia_papers, :revision
        remove_column :snpedia_papers, :revision
      end

      change_table :snpedia_papers do |s|
          s.integer :revision, default: 0
      end
      SnpediaPaper.all.each do |sp|
          sp.update_attribute :revision, 0
      end
  end

  def self.down
        remove_column :snpedia_papers, :revision
  end
end
