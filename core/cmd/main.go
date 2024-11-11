package main

import (
	"fmt"
	"log"
	"strconv"

	"github.com/chrisdmacrae/com.relirc.core/irc"
)

/**
 * A CLI to the IRC client.
 */
func main() {
	client := irc.NewClient()

	server := promptForInput("Enter the server: ")
	portString := promptForInput("Enter the port: ")
	port, err := strconv.Atoi(portString)
	if err != nil {
		log.Fatalf("Error converting port to int: %v", err)
	}
	nickname := promptForInput("Enter the nickname: ")
	realname := promptForInput("Enter the realname: ")
	useAuth := promptForBoolean("Do you want to use authentication?")
	var username, password string
	if useAuth {
		username = promptForInput("Enter the username: ")
		password = promptForInput("Enter the password: ")
	}

	err = client.Connect(server, port, nickname, realname, &username, &password)
	if err != nil {
		log.Fatalf("Error connecting to IRC: %v", err)
	}
	defer client.Disconnect()

	err = client.JoinChannel("#relirc")
	if err != nil {
		log.Fatalf("Error joining channel: %v", err)
	}

	client.ReadUserInput()
}

func promptForBoolean(prompt string) bool {
	var input string
	log.Printf("% s (y/n): ", prompt)
	_, err := fmt.Scanln(&input)
	if err != nil {
		log.Fatalf("Error reading input: %v", err)
	}

	// re-promt if the input is not "y" or "n"
	for input != "y" && input != "n" {
		log.Printf("Invalid input: %s\n", input)
		log.Printf("% s (y/n): ", prompt)
		_, err = fmt.Scanln(&input)
		if err != nil {
			log.Fatalf("Error reading input: %v", err)
		}
	}

	return input == "y"
}

func promptForInput(prompt string) string {
	var input string
	log.Printf("% s: ", prompt)
	_, err := fmt.Scanln(&input)
	if err != nil {
		log.Fatalf("Error reading input: %v", err)
	}

	return input
}
