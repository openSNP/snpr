RSpec.describe Preparsing do
  subject(:worker) { described_class.new }

  let!(:genotype) do
    create(
      :genotype,
      genotype: Rails.root.join("spec/fixtures/files/broken_genotype_file.gz").open
    )
  end

  it "handles errors" do
    expect { worker.perform(genotype.id) }
      .to raise_error(ArgumentError, "invalid byte sequence in UTF-8")

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject)
      .to eq("openSNP.org: Something went wrong while parsing")
  end
end
