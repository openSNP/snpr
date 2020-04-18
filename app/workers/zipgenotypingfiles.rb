# frozen_string_literal: true

class Zipgenotypingfiles
  include Sidekiq::Worker
  sidekiq_options queue: :zipgenotyping, retry: 5, unique: true

  def perform(phenotype_id, variation, target_address)
    @phenotype = Phenotype.find(phenotype_id)
    @variation = variation
    @target_address = target_address
    @time = Time.now.to_s.gsub(':', '_')

    if genotypes.empty?
      send_no_results
      return
    else
      zip_genotypes
      send_results
    end
  end

  def zip_genotypes
    return if File.exist?(zip_file_path)

    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
      genotypes.each do |genotype|
        zipfile.add(
          zipped_file_name(genotype),
          Rails.root.join('public', 'data', genotype.fs_filename)
        )
      end
    end
    File.chmod(0777, zip_file_path)
  end

  def send_results
    UserMailer.genotyping_results(
      target_address,
      zip_file_path.to_s,
      phenotype.characteristic,
      variation
    ).deliver_later
  end

  def zipped_file_name(genotype)
    "user#{genotype.user_id}_file#{genotype.id}_yearofbirth" \
      "#{genotype.user.yearofbirth}_sex#{genotype.user.sex}.#{genotype.filetype}.txt"
  end

  def send_no_results
    UserMailer.no_genotyping_results(
      target_address,
      phenotype.characteristic,
      variation
    ).deliver_later
  end

  private

  attr_reader :phenotype, :variation, :target_address, :time

  def genotypes
    @genotypes ||= user_phenotypes.includes(:user).flat_map do |user_phenotype|
      user_phenotype.user.genotypes
    end
  end

  def user_phenotypes
    UserPhenotype
      .where(phenotype_id: phenotype.id)
      .search(variation)
  end

  def zip_file_path
    @zip_file_path ||= Rails.root.join(
      'public',
      'data',
      'zip',
      "#{phenotype.id}.#{time.to_s.gsub(' ', '_')}.zip"
    )
  end
end
