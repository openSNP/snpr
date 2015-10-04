FactoryGirl.define do
  factory :snp do
    sequence(:name) { |i| "rs#{i}" }
    sequence(:position) { |i| i }
    sequence(:chromosome) { |i| i }
    genotype_frequency('AA' => 1)
    allele_frequency('A' => 0, 'T' => 0, 'G' => 0, 'C' => 0)
    ranking 0
  end
end
