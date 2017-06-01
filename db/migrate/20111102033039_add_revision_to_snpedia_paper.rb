# frozen_string_literal: true
class AddRevisionToSnpediaPaper < ActiveRecord::Migration
  def self.up
    add_column :snpedia_papers, :revision, :int, default: 0
    SnpediaPaper.all.each do |paper|
      paper.update_attributes(revision: 0)
    end
  end

  def self.down
    remove_column :snpedia_papers, :revision
  end
end
