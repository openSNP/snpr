class AddSnpPosChromIndex < ActiveRecord::Migration
  def self.up
      add_index :snps, [:chromosome, :position], :name => "index_snps_chromosome_position"
  end

  def self.down
      remove_index :snps, [:chromosome, :position]
  end
end
