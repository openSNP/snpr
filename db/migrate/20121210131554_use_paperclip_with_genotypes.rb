class UsePaperclipWithGenotypes < ActiveRecord::Migration
  def self.up
    add_attachment :genotypes, :genotype
    ActiveRecord::Base.connection.execute(<<-SQL)
      update genotypes set genotype_file_name = originalfilename,
        genotype_content_type = 'test/plain',
        genotype_updated_at = uploadtime 
        where genotype_file_name is null
    SQL
    remove_column :genotypes, :originalfilename
    remove_column :genotypes, :uploadtime
  end

  def self.down
    add_column :genotypes, :originalfilename, :string
    add_column :genotypes, :uploadtime, :datetime
    ActiveRecord::Base.connection.execute(<<-SQL)
      update genotypes set originalfilename = genotype_file_name,
        uploadtime = genotype_updated_at
        where originalfilename is null
    SQL
    remove_attachment :genotypes, :genotype
  end
end
