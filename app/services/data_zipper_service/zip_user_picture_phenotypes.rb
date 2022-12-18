# frozen_string_literal: true

class DataZipperService
  class ZipUserPicturePhenotypes
    CSV_BASE_HEADER = %w(user_id date_of_birth chrom_sex)

    def initialize(zipfile, tmp_dir, time_str, output_dir)
      @zipfile = zipfile
      @tmp_dir = tmp_dir
      @time_str = time_str
      @output_dir = output_dir
    end

    attr_reader :zipfile, :tmp_dir, :time_str, :output_dir

    def call
      csv_path = tmp_dir.join("picture_dump#{time_str}.csv")
      picture_phenotypes = PicturePhenotype.order(:id)
      csv_head = CSV_BASE_HEADER + picture_phenotypes.pluck(:characteristic)
      picture_zip = Zip::File.open(
        output_dir.join("opensnp_picturedump.#{time_str}.zip"),
        Zip::File::CREATE
      )

      user_picture_phenotypes_csv = CSV.generate(CSV_OPTIONS) do |csv|
        csv << csv_head

        User
          .order(:id)
          .includes(:user_picture_phenotypes)
          .find_each do |user|
            csv << build_user_picture_phenotype_row(user, picture_phenotypes, picture_zip)
          end
        end

      picture_zip.close

      zipfile.get_output_stream("picture_phenotypes_#{time_str}.csv") do |f|
        f.write(user_picture_phenotypes_csv)
      end
      zipfile.add("picture_phenotypes_#{time_str}_all_pics.zip", picture_zip.name)
    end

    def build_user_picture_phenotype_row(user, picture_phenotypes, picture_zip)
      user_picture_phenotypes = user
                                .user_picture_phenotypes
                                .index_by(&:picture_phenotype_id)

      [
        user.id,
        user.yearofbirth,
        user.sex
      ] + picture_phenotypes.map do |picture_phenotype|
        user_picture_phenotype = user_picture_phenotypes[picture_phenotype.id]
        if user_picture_phenotype
          extension = user_picture_phenotype
                      .phenotype_picture
                      .content_type
                      .split('/')
                      .last
          extension = 'jpg' if extension == 'jpeg'
          file_name = "#{user_picture_phenotype.id}.#{extension}"
          picture_zip.add(file_name, user_picture_phenotype.phenotype_picture.path)
          file_name
        else
          '-'
        end
      end
    end
  end
end
