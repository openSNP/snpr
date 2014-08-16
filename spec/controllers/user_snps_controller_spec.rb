require 'spec_helper'

describe UserSnpsController do
  let(:user_snp) { double('user_snp') }

  describe 'GET #index' do
    it 'assigns user_snps' do
      expect(Snp).to receive(:find_by).with(name: 'rs1').and_return(Snp)
      expect(Snp).to receive(:user_snps).and_return(Snp)
      expect(Snp).to receive(:includes).with(:user).and_return([user_snp])
      get :index, local_genotype: 'AG', snp_name: 'rs1'
      expect(assigns(:user_snps)).to eq([user_snp])
    end
  end
end
