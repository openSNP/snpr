require 'open3'

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  attr_reader :genotype, :temp_table_name, :tempfile

  def perform(genotype_id)
    logger.info("Started parsing genotype with id #{genotype_id}")
    @genotype = Genotype.find(genotype_id)
    @temp_table_name = "user_snps_temp_#{genotype.id}"
    @tempfile = Tempfile.new("snpr_genotype_#{genotype.id}_")
    create_temp_table
    normalize_csv
    copy_csv_into_temp_table
    insert_into_snps
    insert_into_user_snps
    logger.info("Finished parsing genotype with id #{genotype.id}, cleaning up.")
  rescue => e
    logger.error("Failed with #{e.class}: #{e.message}")
    raise
  ensure
    drop_temp_table
    # TODO: Why doesn't `tempfile.unlink` work here?
    File.delete(tempfile.path)
  end

  def create_temp_table
    execute("drop table if exists #{temp_table_name}")
    execute(<<-SQL)
      create table #{temp_table_name} (
        genotype_id int,
        snp_name varchar(32),
        chromosome varchar(32),
        position int,
        local_genotype char(2)
      )
    SQL
  end

  def drop_temp_table
    execute("drop table #{temp_table_name}")
  end

  def normalize_csv
    csv = File.readlines(genotype.genotype.path).
      reject { |line| line.start_with?('#') }.
      drop(config.fetch(:skip, 0)).
      map do |line|
        fields = line.strip.split(config[:separator])
        [
          genotype.id,
          fields[config[:snp_name]],
          fields[config[:chromosome]],
          fields[config[:position]],
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
      copy #{temp_table_name} (
        genotype_id,
        snp_name,
        chromosome,
        position,
        local_genotype
      )
      from '#{tempfile.path}'
      with (FORMAT CSV, HEADER FALSE, DELIMITER ',')
    SQL
  end

  def insert_into_snps
    time = Time.now.utc.iso8601
    execute(<<-SQL)
      insert into snps (name, chromosome, position, created_at, updated_at, user_snps_count)
      (
        select
          #{temp_table_name}.snp_name,
          #{temp_table_name}.chromosome,
          #{temp_table_name}.position,
          '#{time}',
          '#{time}',
          1
        from #{temp_table_name}
        left join snps
          on #{temp_table_name}.snp_name = snps.name
        where
          snps.name is null
      )
    SQL
  end

  def insert_into_user_snps
    execute(<<-SQL)
      insert into user_snps (snp_name, local_genotype, genotype_id)
      (
        select
          #{temp_table_name}.snp_name,
          #{temp_table_name}.local_genotype,
          #{temp_table_name}.genotype_id
        from #{temp_table_name}
        left join user_snps
          on user_snps.snp_name = #{temp_table_name}.snp_name
          and user_snps.genotype_id = #{temp_table_name}.genotype_id
        where user_snps.snp_name is null
      )
    SQL
  end

  def config
    {
      '23andme' => {
        separator: "\t",
        snp_name: 0,
        chromosome: 1,
        position: 2,
        local_genotype: 3,
      },
      'decodeme' => {
        separator: ',',
        snp_name: 0,
        chromosome: 2,
        position: 3,
        local_genotype: 5,
        skip: 1,
      }
    }.fetch(genotype.filetype) { raise "Unknown filetype: #{genotype.filetype}" }
  end

  def execute(sql)
    Genotype.connection.execute(sql)
  end

  def logger
    return @logger if @logger
    @logger = Logger.new(Rails.root.join("log/parsing_#{Rails.env}.log"))
    @logger.formatter = Logger::Formatter.new
    @logger
  end
end

