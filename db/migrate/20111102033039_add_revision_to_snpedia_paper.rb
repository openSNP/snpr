class AddRevisionToSnpediaPaper < ActiveRecord::Migration
  def self.up
		add_column :snpedia_papers, :revision, :int
  end

  def self.down
		remove_column :snpedia_papers, :revision
  end
end
