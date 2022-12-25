# frozen_string_literal: true

describe DataZipperService do
  subject(:service) { described_class.new(output_dir: output_dir, logger: logger) }

  let(:output_dir) { Rails.root.join('tmp', 'test', 'zipfulldata') }
  let(:symlink) { output_dir.join('opensnp_datadump.current.zip') }
  let(:picture_zip) { Dir[output_dir.join('opensnp_picturedump.*.zip')].last }
  let(:logger) { instance_double(Logger) }

  before do
    FileUtils.mkdir_p(output_dir)
    # Add dummy phenotype so the CROSSTAB queries don't trip.
    create(:phenotype, characteristic: 'affinity for filling out online questionaires')
    allow(logger).to receive(:info)
  end

  after do
    FileUtils.rm_rf(output_dir)
  end

  it 'creates a new dump file and symlink' do
    service.call

    expect(File.symlink?(symlink)).to be(true)
    expect(File.exist?(File.readlink(symlink)))
  end

  it 'adds a README' do
    service.call

    Zip::File.open(symlink) do |zip|
      readme = zip.read('readme.txt')
      expect(readme).to eq(<<~README)
        This archive was generated on #{service.time.ctime} UTC. \
        It contains 1 phenotypes, 0 genotypes and 0 picture phenotypes.

        Thanks for using openSNP!
      README
    end
  end

  it 'adds a phenotype csv' do
    service.call

    Zip::File.open(symlink) do |zip|
      expect(zip.glob('phenotypes_*.csv')).to be_present
    end
  end

  it 'adds a picture phenotype zip and csv' do
    service.call

    Zip::File.open(symlink) do |zip|
      expect(zip.glob('picture_phenotypes_*.csv')).to be_present
      expect(zip.glob('picture_phenotypes_*_all_pics.zip')).to be_present
    end
  end

  it 'adds genotype files to the ZIP' do
    create(:genotype)

    service.call

    Zip::File.open(symlink) do |zip|
      expect(zip.glob('user*.txt').count).to eq(1)
    end
  end

  context 'when deleting files' do
    let(:unrelated_file_path) { output_dir.join('do_not_delete_me.zip') }
    let(:old_dump_file_path) { output_dir.join('opensnp_datadump.197001010000.zip') }

    before do
      [unrelated_file_path, old_dump_file_path].each do |path|
        FileUtils.touch(path)
      end
    end

    it 'deletes old dump files' do
      service.call

      expect(File.exist?(old_dump_file_path)).to be(false)
    end

    it 'does not delete unrelated files' do
      service.call

      expect(File.exist?(unrelated_file_path)).to be(true)
    end

    after do
      [unrelated_file_path, old_dump_file_path].each do |path|
        FileUtils.rm(path) if File.exist?(path)
      end
    end
  end

  describe '.public_path' do
    it 'returns the public path of the zip file' do
      expect(described_class.public_path)
        .to eq('/data/zip/opensnp_datadump.current.zip')
    end
  end
end
