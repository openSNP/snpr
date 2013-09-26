package main

import (
	"database/sql"
	"fmt"
	"github.com/benmanns/goworker"
	_ "github.com/bmizerany/pq"
)

// Parse is a function that receives the name of the queue, all arguments to the queue, and returns error
func goParseFunc(queue string, args ...interface{}) error {
	// Connect to database
	// TODO: Use a closure here so that workers can share DB-connection
	db, err := sql.Open("postgres", "user=root password=root dbname=snpr_development sslmode=disable")
	if err {
		return err
	}
	_ = db

	// Parse the file
	fmt.Printf("From %s, %v", queue, args)
	return nil
}

func init() {
	// The name of the queue in redis is "goParse"
	goworker.Register("goParse", goParseFunc)
}

func main() {
	// Just work until we die. TODO: Requeue job on failure
	if err := goworker.Work(); err != nil {
		fmt.Println("Error:", err)
	}
}
