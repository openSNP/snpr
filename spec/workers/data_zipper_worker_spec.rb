# frozen_string_literal: true

RSpec.describe DataZipperWorker do
  subject(:worker) { described_class.new }

  let(:data_zipper_service) { instance_double(DataZipperService) }

  describe '#perform' do
    it 'calls DataZipperService' do
      expect(DataZipperService)
        .to receive(:new)
        .with(logger: worker.logger)
        .and_return(data_zipper_service)
      expect(data_zipper_service).to receive(:call)

      worker.perform
    end
  end
end
