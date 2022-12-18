RSpec.describe ApplicationRecord do
  describe '.copy_csv' do
    it 'returns an enumerator' do
      expect(described_class.copy_csv('SELECT 1')).to be_a(Enumerator)
    end

    it 'returns the query result as an Array of CSV rows' do
      expect(described_class.copy_csv('SELECT 1 AS foo, 2 AS bar').to_a)
        .to eq(["foo;bar\n", "1;2\n"])
    end
  end
end
