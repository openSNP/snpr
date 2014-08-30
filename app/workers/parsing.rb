require 'open3'

class Parsing
  include Sidekiq::Worker
  sidekiq_options :queue => :parse, :retry => 5, :unique => true

  attr_reader :genotype, :temp_table_name, :tempfile, :stats, :start_time

  def perform(genotype_id)
    @stats = {}
    @start_time = Time.current
    logger.info("Started parsing genotype with id #{genotype_id}")
    @genotype = Genotype.find(genotype_id)
    stats[:filetype] = genotype.filetype
    stats[:genotype_id] = genotype.id
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
    stats[:duration] = "#{(Time.current - start_time).round(3)}s"
    logger.info("Stats: #{stats.to_a.map { |s| s.join('=') }.join(', ')}")
  end

  def create_temp_table
    execute("drop table if exists #{temp_table_name}")
    execute(<<-SQL)
      create table #{temp_table_name} (
        genotype_id int,
        snp_name varchar(32),
        chromosome varchar(32),
        position varchar(32),
        local_genotype char(2)
      )
    SQL
  end

  def drop_temp_table
    execute("drop table #{temp_table_name}")
  end

  def normalize_csv
    rows = File.readlines(genotype.genotype.path)
      .reject { |line| line.start_with?('#') } # Skip comments
    stats[:rows_without_comments] = rows.length
    csv = send(:"parse_#{genotype.filetype}", rows)
    csv.select! do |row|
      # snp name
      row[1].present? &&
      # chromosome
      ['MT', 'X', 'Y', (1..22).to_a].flatten.include?(row[2]) &&
      # position
      row[3].to_i < 0
      # local genotype
      row[4].is_a?(String) &&
      row[4].length > 0 &&
      (1..2).include?(row[4].length)
    end
    stats[:rows_after_parsing] = csv.length
    tempfile.write(csv.join("\n"))
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

  def parse_23andme(rows)
    rows.map do |row|
      fields = row.strip.split("\t")
      [
        genotype.id,
        fields[0],
        fields[1],
        fields[2],
        fields[3]
      ].join(',')
    end
  end

  def parse_decodeme(rows)
    rows.shift if rows.first.start_with?('Name')
    rows.map do |row|
      fields = row.strip.split(',')
      [
        genotype.id,
        fields[0],
        fields[2],
        fields[3],
        fields[5]
      ].join(',')
    end
  end

  def parse_ancestry(rows)
    rows.shift if rows.first.start_with?('rsid')
    rows.map do |row|
      fields = row.strip.split("\t")
      [
        genotype.id,
        fields[0],
        fields[1],
        fields[2],
        "#{fields[3]}#{fields[4]}"
      ].join(',')
    end
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

