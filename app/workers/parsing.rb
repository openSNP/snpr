class Parsing
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  attr_reader :genotype, :temp_table_name, :normalized_csv, :stats, :start_time

  def perform(genotype_id)
    @stats = {}
    @start_time = Time.current
    @genotype = Genotype.find(genotype_id)
    logger.info("Started parsing #{genotype.filetype} genotype with id #{genotype_id}")
    stats[:filetype] = genotype.filetype
    stats[:genotype_id] = genotype.id
    @temp_table_name = "user_snps_temp_#{genotype.id}"

    send_logged(:normalize_csv)
    ActiveRecord::Base.transaction do
      send_logged(:create_temp_table)
      send_logged(:copy_csv_into_temp_table)
      send_logged(:insert_into_snps)
      send_logged(:insert_into_user_snps)
    end
    send_logged(:notify_user)

    stats[:duration] = "#{(Time.current - start_time).round(3)}s"
    logger.info("Finished parsing: #{stats.to_a.map { |s| s.join('=') }.join(', ')}")
  rescue => e
    logger.error("Failed with #{e.class}: #{e.message}")
    raise
  end

  def create_temp_table
    execute(<<-SQL)
      CREATE TEMPORARY TABLE #{temp_table_name} (
        snp_name varchar(32),
        chromosome varchar(32),
        position varchar(32),
        local_genotype char(2)
      ) ON COMMIT DROP
    SQL
  end

  def normalize_csv
    rows = File.readlines(genotype.genotype.path)
      .reject { |line| line.start_with?('#') } # Skip comments
    stats[:rows_without_comments] = rows.length
    csv = send(:"parse_#{genotype.filetype.gsub('-', '_').downcase}", rows)
    known_chromosomes = ['MT', 'X', 'Y', (1..22).map(&:to_s)].flatten
    csv.select! do |row|
      # snp name
      row[0].present? &&
      # chromosome
      known_chromosomes.include?(row[1]) &&
      # position
      row[2].to_i >= 1 && row[2].to_i <= 249_250_621 &&
      # local genotype
      row[3].is_a?(String) && (1..2).include?(row[3].length)
    end
    @normalized_csv = csv.map { |row| row.join(',') }.join("\n")
    stats[:rows_after_parsing] = csv.length
  end

  def copy_csv_into_temp_table
    sql = <<-SQL
      COPY #{temp_table_name} (
        snp_name,
        chromosome,
        position,
        local_genotype
      )
      FROM STDIN
      WITH (FORMAT CSV, HEADER FALSE, DELIMITER ',')
    SQL

    raw = connection.raw_connection
    raw.copy_data(sql) do
      raw.put_copy_data(normalized_csv)
    end
  end

  def insert_into_snps
    time = Time.now.utc.iso8601

    snps = execute(<<-SQL)
      select
        #{temp_table_name}.snp_name as name,
        #{temp_table_name}.chromosome,
        #{temp_table_name}.position,
        1 as user_snps_count
      from #{temp_table_name}
      left join snps on #{temp_table_name}.snp_name = snps.name
      where snps.name is null
    SQL
    Snp.create!(snps.to_a)
  end

  def insert_into_user_snps
    execute("SELECT upsert_user_snps(#{genotype.id})")
  end

  def parse_23andme(rows)
    rows.map do |row|
      fields = row.strip.split("\t")
      [
        fields[0],
        fields[1],
        fields[2],
        fields[3].to_s.rstrip
      ]
    end
  end

  def parse_23andme_exome_vcf(rows)
    # Rules:
    # Skip lines with IndelType in them
    # Skip lines were SNP name is '.', these are non-standard SNPs
    rows.map do |row|
      next if row.include? 'IndelType'
      fields = row.strip.split("\t")
      next if fields[2] == '.'
      major_allele = fields[3] # C
      minor_allele = fields[4] # A
      trans_dict = {"0" => major_allele, "1" => minor_allele}
      names = fields[-1].split(":")[0].split("/") # ["0", "1"], meaning A/C
      alleles = names.map{ |a| trans_dict[a]}.sort.join # becomes AC
      [
        fields[2],
        fields[0],
        fields[1],
        alleles
      ]
    end.compact # because the above next introduces nil.
    # Slower alternative is to use reject first, but then we'll iterate > 2 times
  end

  def parse_decodeme(rows)
    rows.shift if rows.first.start_with?('Name')
    rows.map do |row|
      fields = row.strip.split(',')
      [
        fields[0],
        fields[2],
        fields[3],
        fields[5]
      ]
    end
  end

  def parse_ancestry(rows)
    rows.shift if rows.first.start_with?('rsid')
    rows.map do |row|
      fields = row.strip.split("\t")
      [
        fields[0],
        fields[1],
        fields[2],
        "#{fields[3]}#{fields[4]}"
      ]
    end
  end

  def parse_ftdna_illumina(rows)
    rows.shift if rows.first.start_with?('RSID')
    rows.map do |row|
      fields = row.strip.split(',')
      [
        fields[0].to_s.gsub('"', ''),
        fields[1].to_s.gsub('"', ''),
        fields[2].to_s.gsub('"', ''),
        fields[3].to_s.gsub('"', '')
      ]
    end
  end

  def parse_iyg(rows)
    db_snp_names = {
      "MT-T3027C" => "rs199838004", "MT-T4336C" => "rs41456348",
      "MT-G4580A" => "rs28357975", "MT-T5004C" => "rs41419549",
      "MT-C5178a" => "rs28357984", "MT-A5390G" => "rs41333444",
      "MT-C6371T" => "rs41366755", "MT-G8697A" => "rs28358886",
      "MT-G9477A" => "rs2853825", "MT-G10310A" => "rs41467651",
      "MT-A10550G" => "rs28358280", "MT-C10873T" => "rs2857284",
      "MT-C11332T" => "rs55714831", "MT-A11947G" => "rs28359168",
      "MT-A12308G" => "rs2853498", "MT-A12612G" => "rs28359172",
      "MT-T14318C" => "rs28357675", "MT-T14766C" => "rs3135031",
      "MT-T14783C" => "rs28357680"
    }
    rows.map do |row|
      snp_name, local_genotype = row.strip.split("\t")
      if snp_name.start_with?('MT')
        position = snp_name[/[0-9]+/]
        chromosome = 'MT'
      else
        position = chromosome = '1'
      end
      [
        db_snp_names.fetch(snp_name, snp_name),
        chromosome,
        position,
        local_genotype.strip
      ]
    end
  end

  def notify_user
    UserMailer.finished_parsing(genotype.id, stats).deliver_later
  end

  def execute(sql)
    connection.execute(sql)
  end

  def connection
    ActiveRecord::Base.connection
  end

  def send_logged(method)
    start_time = Time.now
    ret = send(method)
    took = Time.now - start_time
    logger.info("calling of method `#{method}` took #{took} s")
    ret
  end
end
