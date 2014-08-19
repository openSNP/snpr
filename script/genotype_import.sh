#!/usr/bin/env bash

set -e
genotype_id=42
temp_table_name="user_snps_temp_${genotype_id}"
file='/home/helge/Downloads/1.23andme.9.txt'

psql snpr_development -c "drop table if exists ${temp_table_name}"
psql snpr_development -c "create table ${temp_table_name} (like user_snps)"

cat "${file}" | \
  grep -v '#' | \
  cut -f 1,4 --output-delimiter=, | \
  sed "s/^/${genotype_id},/" | \
  psql snpr_development -c "copy ${temp_table_name} (genotype_id,snp_name,local_genotype) from STDIN with (FORMAT CSV, HEADER FALSE, DELIMITER ',')"

psql snpr_development -c "insert into user_snps (select ${temp_table_name}.* from ${temp_table_name} left join user_snps on user_snps.snp_name = ${temp_table_name}.snp_name and user_snps.genotype_id = ${temp_table_name}.genotype_id where user_snps.snp_name is null)"

psql snpr_development -c "drop table ${temp_table_name}"

