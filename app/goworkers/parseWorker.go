package main

import (
	"database/sql"
	"flag"
	"fmt"
	"github.com/benmanns/goworker"
	_ "github.com/bmizerany/pq"
	"io/ioutil"
	"strconv"
	"strings"
)

func newGoParser(environment string, args ...interface{}) (func(string, ...interface{}) error, error) {
	// Get username, password for database from database.yml
	configFile := "../../config/database.yml" // TODO: Make this less error-prone
	config, err := ioutil.ReadFile(configFile)
	if err != nil {
		return nil, err
	}

	// TODO: this is ugly. Unfortunately, all YAML packages for Go are ugly, too.
	configs := strings.Split(string(config), "\n")
	inside := false
	database_name := "snpr_development"
	username := "root"
	password := "root"
	port := "5432"
	max_conns := 25
	for _, element := range configs {
		// Are we in the right environment?
		if element == environment+":" {
			// Flip the switch so that the next field containining "database" is the name of our database
			inside = true
		}
		if strings.Contains(element, "database:") && inside {
			database_name = strings.Trim(strings.Split(element, ": ")[1], " ")
			inside = false
		}
		if strings.Contains(element, "port:") {
			port = strings.Trim(strings.Split(element, ": ")[1], " ")
		}
		if strings.Contains(element, "username:") {
			username = strings.Trim(strings.Split(element, ": ")[1], " ")
		}
		if strings.Contains(element, "password:") {
			password = strings.Trim(strings.Split(element, ": ")[1], " ")
		}
		if strings.Contains(element, "pool:") {
			max_conns, err = strconv.Atoi(strings.Trim(strings.Split(element, ": ")[1], " "))
			if err != nil {
				return nil, err
			}
		}
	}
	// Connect to database
	connection_string := "user=" + username + " password=" + password + " dbname=" + database_name + " sslmode=disable port=" + port
	fmt.Println(connection_string)
	db, err := sql.Open("postgres", connection_string)
	if err != nil {
		return nil, err
	}
	_ = db
	db.SetMaxIdleConns(max_conns)

	return func(queue string, args ...interface{}) error {
		// Parse the file
		fmt.Printf("From %s, %v", queue, args)
		return nil // TODO: replace by actual errors
	}, nil
}

func init() {
	// Get the environment, possible values: development, production, test
	var environment string
	flag.StringVar(&environment, "environment", "development", "Name of the Rails environment this worker runs in")
	// Create workers
	parseWorker, err := newGoParser(environment)
	if err != nil {
		fmt.Println("Error creating worker:", err)
		return
	}
	// Register workers
	// The name of the queue in redis is "goParse"
	goworker.Register("goParse", parseWorker)
}

func main() {
	// Do the actual work
	// TODO: If we have several go-workers with different jobs, only one worker needed with main()-function.
	err := goworker.Work()
	if err != nil {
		fmt.Println("Error running worker:", err)
	}
}
