# frozen_string_literal: true

class DataZipperService
  class ZipGenotypeFiles
    def initialize(zipfile)
      @zipfile = zipfile
    end

    attr_reader :zipfile

    def call
      Genotype.includes(:user).find_each do |genotype|
        next unless File.exist?(genotype.genotype.path)

        user = genotype.user
        yob = user.yearofbirth == "rather not say" ? "unknown" : user.yearofbirth
        sex = user.sex == "rather not say" ? "unknown" : user.sex

        zipfile.add(
          "user#{genotype.user_id}_file#{genotype.id}_yearofbirth_#{yob}_" \
            "sex_#{sex}.#{genotype.filetype}.txt",
          genotype.genotype.path
        )
      end
    end
  end
end
