package main

import (
	"log"

	"github.com/chrisdmacrae/com.relirc.core/irc"
)

/**
 * A CLI to the IRC client.
 */
func main() {
	client := irc.NewClient()

	err := client.Connect("irc.libera.chat", 6697, "GoIRCBot", "GoIRCBot 0 * :Go Bot", nil)
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
