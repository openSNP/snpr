class AddIndexOnMendeleySnp < ActiveRecord::Migration
  def up
    add_index :mendeley_papers, :snp_id
  end

  def down
    remove_index :mendeley_papers, :snp_id
  end
end
