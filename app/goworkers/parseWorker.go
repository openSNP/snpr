package main

import (
	"bufio"
	"database/sql"
	"flag"
	"github.com/benmanns/goworker"
	_ "github.com/bmizerany/pq"
	"io/ioutil"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
)

// To test this worker:
// redis-cli RPUSH resque:queue:goParse '{"class":"goParse", "args":["1","bla.txt"]}'

func newParseWorker(environment string, args ...interface{}) (func(string, ...interface{}) error, error) {
	// This function returns a pool of workers, by default 25

	// A map to switch names for known SNPs
	db_snp_snps := map[string]string{"MT-T3027C": "rs199838004", "MT-T4336C": "rs41456348", "MT-G4580A": "rs28357975", "MT-T5004C": "rs41419549", "MT-C5178a": "rs28357984", "MT-A5390G": "rs41333444", "MT-C6371T": "rs41366755", "MT-G8697A": "rs28358886", "MT-G9477A": "rs2853825", "MT-G10310A": "rs41467651", "MT-A10550G": "rs28358280", "MT-C10873T": "rs2857284", "MT-C11332T": "rs55714831", "MT-A11947G": "rs28359168", "MT-A12308G": "rs2853498", "MT-A12612G": "rs28359172", "MT-T14318C": "rs28357675", "MT-T14766C": "rs3135031", "MT-T14783C": "rs28357680"}
	_ = db_snp_snps

	// TODO: Make file-opening less error-prone
	// Initialize logger
	logFile, err := os.Create("../../log/goworker.log")
	if err != nil {
		log.Println(err)
	}
	log := log.New(logFile, "goworker-", 0)
	log.Println("Started worker-pool")
	// Get username, password for database from database.yml
	configFile := "../../config/database.yml"

	// Read all lines from the configFile into a slice (list) of type []byte
	config, err := ioutil.ReadFile(configFile)
	if err != nil {
		return nil, err
	}

	// TODO: parsing the db-config like this is ugly. Unfortunately, all YAML packages for Go are ugly, too.
	// As an upside, all of the following is run only once.
	configs := strings.Split(string(config), "\n")
	inside := false
	database_name := "snpr_development"
	username := ""
	password := ""
	port := "5432"
	max_conns := 25
	for _, line := range configs {
		// Are we in the right environment?
		if line == environment+":" {
			// Flip the switch so that the next field containining "database" is the name of our database
			inside = true
		}
		if strings.Contains(line, "database:") && inside {
			database_name = strings.Trim(strings.Split(line, ": ")[1], " ")
			inside = false
		}
		if strings.Contains(line, "port:") {
			port = strings.Trim(strings.Split(line, ": ")[1], " ")
		}
		if strings.Contains(line, "username:") {
			username = strings.Trim(strings.Split(line, ": ")[1], " ")
		}
		if strings.Contains(line, "password:") {
			password = strings.Trim(strings.Split(line, ": ")[1], " ")
		}
		if strings.Contains(line, "pool:") {
			max_conns, err = strconv.Atoi(strings.Trim(strings.Split(line, ": ")[1], " "))
			if err != nil {
				return nil, err
			}
		}
	}
	// Connect to database
	connection_string := "user=" + username + " password=" + password + " dbname=" + database_name + " sslmode=disable port=" + port
	db, err := sql.Open("postgres", connection_string)
	if err != nil {
		return nil, err
	}
	db.SetMaxIdleConns(max_conns)

	// Now load the known SNPs
	known_snps := make(map[string]bool) // There is no set-type, so this is a workaround
	rows, err := db.Query("SELECT name FROM snps;")
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			log.Println(err)
			return nil, err
		}
		known_snps[name] = true
	}

	// Return the worker, and return nil for the error
	return func(queue string, args ...interface{}) error {
		// This is the actual worker, the parsing happens here
		// This worker inherits all variables etc. from newInsertWorker()
		// The arguments are:
		// @genotype.id, single_temp_file

		// Get the genotype from the database using @genotype.id
		// We're only interested in genotype.filetype and genotype.user_id
		var (
			filetype string
			user_id  string
		)

		genotype_id := args[0].(string)
		query_string := "SELECT genotypes.filetype, genotypes.user_id FROM genotypes WHERE genotypes.id = " + genotype_id + " LIMIT 1;"
		rows, err := db.Query(query_string)
		if err != nil {
			log.Println(err)
			return err
		}

		for rows.Next() {
			if err := rows.Scan(&filetype, &user_id); err != nil {
				log.Println(err)
				return err
			}
		}
		if err := rows.Err(); err != nil {
			return err
		}

		// Now load the known user-snps
		// Comment: I took this idea from the Rails-parser,
		//          it might be faster to always query the DB instead of creating a dictionary first?
		known_user_snps := make(map[string]bool)
		rows, err = db.Query("SELECT user_snps.snp_name FROM user_snps WHERE user_snps.user_id = " + user_id + ";")
		if err != nil {
			log.Println(err)
			return err
		}
		for rows.Next() {
			var snp_name string
			if err := rows.Scan(&snp_name); err != nil {
				log.Println(err)
				return err
			}
			known_user_snps[snp_name] = true
		}

		if err := rows.Err(); err != nil {
			return err
		}

		// Turn off AUTOCOMMIT by using BEGIN / INSERTs / COMMIT
		// More tips at http://www.postgresql.org/docs/current/interactive/populate.html,
		// TODO: Implement more improvements, maybe use PREPARE or even just COPY?

		db.Exec("BEGIN")
		// Now, finally, open the single_temp_file and create userSNPs
		tmp_file := args[1].(string)
		log.Println("Started work on " + tmp_file)
		var file *os.File
		if file, err = os.Open(tmp_file); err != nil {
			log.Println(err)
			return err
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "#") {
				// Skip comments
				continue
			}
			line = strings.ToLower(strings.Trim(line, "\n"))
			// Fix the linelist for all different filetypes
			// Nothing much to do for 23andme
			var linelist []string
			if filetype == "23andme" {
				linelist = strings.Split(line, "\t")
			} else if filetype == "ancestry" {
				linelist := strings.Split(line, "\t")
				if linelist[0] != "rsid" {
					linelist = []string{linelist[0], linelist[1], linelist[3], linelist[4] + linelist[5]}
				} else {
					continue
				}
			} else if filetype == "decodeme" {
				linelist := strings.Split(line, ",")
				if linelist[0] == "Name" {
					// skip header
					continue
				}
				linelist = []string{linelist[0], linelist[2], linelist[3], linelist[5]}
			} else if filetype == "ftdna-illumina" {
				// Remove "
				line = strings.Replace(line, `"`, "", -1) // Backticks are needed here.
				linelist := strings.Split(line, ",")
				if linelist[0] == "RSID" {
					// skip header
					continue
				}
				// Interestingly, from here on ftdna has the same format as 23andme
			} else if filetype == "23andme-exome-vcf" {
				// This is a valid VCF so a bit more work is needed
				linelist := strings.Split(line, "\t")
				format_array := strings.Split(linelist[8], ":")
				genotype_index := -1
				for index, element := range format_array {
					if element == "GT" {
						genotype_index = index
						break
					}
				}
				non_genotype_parsed := strings.Split(strings.Split(linelist[9], ":")[genotype_index], "/")
				genotype_parsed := ""
				for _, allele := range non_genotype_parsed {
					if allele == "0" {
						genotype_parsed = genotype_parsed + linelist[3]
					} else if allele == "1" {
						genotype_parsed = genotype_parsed + linelist[4]
					}
				}
				linelist = []string{strings.ToLower(linelist[2]), linelist[0], linelist[1], strings.ToUpper(genotype_parsed)}

			} else if filetype == "IYG" {
				linelist := strings.Split(line, "\t")
				name := linelist[0]
				// Have to get the position from the name
				// TODO: This is an ugly hack - first, replace all runes
				// which are letters by X, then replace that X by nothing
				replace_letters := func(r rune) rune {
					switch {
					case r >= 'A' && r <= 'Z':
						return 'X'
					case r >= 'a' && r <= 'z':
						return 'X'
					}
					return r
				}
				position := strings.Map(replace_letters, name)
				position = strings.Replace(position, "X", "", -1)
				if strings.HasPrefix(name, "MT") {
					// Check whether we have to replace the name with the correct rs ID
					new_name, ok := db_snp_snps[name]
					if ok {
						name = new_name
					}
					linelist = []string{name, "MT", position, linelist[1]}
				} else {
					linelist = []string{linelist[0], "1", "1", linelist[1]}
				}

			} else {
				log.Println("unknown filetype", filetype)
			}

			// Example:
			// ["rs123", "11", "421412", "aa"]
			snp_name := linelist[0]
			chromosome := strings.ToUpper(linelist[1]) // mt -> MT
			position := linelist[2]
			allele := strings.ToUpper(linelist[3])
			// Is this a known SNP?
			_, ok := known_snps[snp_name]
			if !ok {
				// Create a new SNP
				time := time.Now().UTC().Format(time.RFC3339)
				// possibly TODO: Initialize the genotype frequencies, allele frequencies
				insertion_string := "INSERT INTO snps (name, chromosome, position, ranking, created_at, updated_at) VALUES ('" + snp_name + "','" + chromosome + "','" + position + "','0','" + time + "', '" + time + "');"
				_, err := db.Exec(insertion_string) // Notice the difference here - using Exec instead of Query, we don't need any rows returned
				if err != nil {
					log.Println(err)
					return err
				}
			}
			// Is this a known userSNP?
			_, ok = known_user_snps[snp_name]
			if !ok {
				// Create a new userSNP
				time := time.Now().Format(time.RFC3339)
				// snp_id is deprecated, just use snp_name
				user_snp_insertion_string := "INSERT INTO user_snps (local_genotype, genotype_id, user_id, created_at, updated_at, snp_name) VALUES ('" + allele + "','" + genotype_id + "','" + user_id + "','" + time + "','" + time + "','" + snp_name + "');"
				_, err := db.Exec(user_snp_insertion_string)
				if err != nil {
					log.Println(err)
					return err
				}
			} else {
				log.Println("User-SNP " + snp_name + " with allele " + allele + " already exists")
			}

		} // End of file-parsing
		log.Println("Running COMMIT")
		_, err = db.Exec("COMMIT")
		if err != nil {
			log.Println(err)
			return err
		}
		// Update our indexes
		// Both of these should only take a few seconds
		log.Println("Vacuuming...")
		db.Exec("VACUUM ANALYZE snps")
		db.Exec("VACUUM ANALYZE user_snps")
		log.Println("Done!")
		return nil // Parsing the file went fine, return "nil" as error
	}, nil // Worker-creation went fine
}

func init() {
	// Get the environment, possible values: development, production, test
	var environment string
	flag.StringVar(&environment, "environment", "development", "Name of the Rails environment this worker runs in.")
	// Create workers
	parseWorker, err := newParseWorker(environment)
	if err != nil {
		log.Println("Error creating worker:", err)
		return
	}
	// Register workers
	// The name of the queue in redis is "goParse"
	goworker.Register("goParse", parseWorker)
}

func main() {
	// Do the actual work
	// TODO: If we have several go-workers with different jobs, only one "main"-worker needed with main()-function.
	err := goworker.Work()
	if err != nil {
		log.Println("Error running worker:", err)
	}
}
