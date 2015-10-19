RSpec.describe 'upsert_user_snps' do
  let(:genotype) { create(:genotype) }
  let(:snp) { create(:snp, name: 'rs1') }
  let!(:existing_user_snp) { create(:user_snp, genotype: genotype, snp: snp, local_genotype: 'AG') }
  let(:temp_table_name) { "user_snps_temp_#{genotype.id}" }

  before do
    ActiveRecord::Base.connection.execute(<<-SQL)
      CREATE TEMPORARY TABLE #{temp_table_name} (
        snp_name varchar(32),
        chromosome varchar(32),
        position varchar(32),
        local_genotype char(2)
      ) ON COMMIT DROP;
 
      INSERT INTO #{temp_table_name} (snp_name, local_genotype)
      VALUES ('rs1', 'AA'), ('rs2', 'AC');
    SQL

    ActiveRecord::Base.connection.execute("SELECT upsert_user_snps(#{genotype.id})")
  end

  it 'inserts a new user-SNP' do
    expect(UserSnp.find_by(snp_name: 'rs1')).to have_attributes(
      'genotype_id' => genotype.id,
      'local_genotype' => 'AA'
    )
  end

  it 'updates existing user-SNP' do
    expect(UserSnp.find_by(snp_name: 'rs2')).to have_attributes(
      'genotype_id' => genotype.id,
      'local_genotype' => 'AC'
    )
  end
end
