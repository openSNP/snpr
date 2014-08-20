require 'open3'

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  attr_reader :genotype, :temp_table_name, :tempfile

  def perform(genotype_id)
    @genotype = Genotype.find(genotype_id)
    return unless genotype
    @temp_table_name = "user_snps_temp_#{genotype.id}"
    @tempfile = Tempfile.new("snpr_genotype_#{genotype.id}_")
    create_temp_table
    normalize_csv
    copy_csv_into_temp_table
    insert_into_user_snps
  ensure
    drop_temp_table
    # TODO: Why doesn't `tempfile.unlink` work here?
    File.delete(tempfile.path)
  end

  def create_temp_table
    execute("drop table if exists #{temp_table_name}")
    execute("create table #{temp_table_name} (like user_snps)")
  end

  def drop_temp_table
    execute("drop table #{temp_table_name}")
  end

  def normalize_csv
    csv = File.readlines(genotype.genotype.path).
      reject { |line| line.start_with?('#') }.
      map do |line|
        fields = line.strip.split(config[:separator])
        [
          genotype.id,
          fields[config[:snp_name]],
          fields[config[:local_genotype]]
        ].join(',')
      end.
      join("\n")

    tempfile.write(csv)
    tempfile.close
    FileUtils.chmod(0644, tempfile.path)
  end

  def copy_csv_into_temp_table
    execute(<<-SQL)
      copy #{temp_table_name} (genotype_id,snp_name,local_genotype)
      from '#{tempfile.path}'
      with (FORMAT CSV, HEADER FALSE, DELIMITER ',')
    SQL
  end

  def insert_into_user_snps
    execute(<<-SQL)
      insert into user_snps (
        select #{temp_table_name}.* from #{temp_table_name}
        left join user_snps
          on user_snps.snp_name = #{temp_table_name}.snp_name
          and user_snps.genotype_id = #{temp_table_name}.genotype_id
        where user_snps.snp_name is null
      )
    SQL
  end

  def config
    {
      '23andme' => { separator: "\t", snp_name: 0, local_genotype: 3 },
    }.fetch(genotype.filetype) { raise "Unknown filetype: #{genotype.filetype}" }
  end

  def execute(sql)
    Genotype.connection.execute(sql)
  end
end

