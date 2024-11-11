package irc

import (
	"bufio"
	"fmt"
	"log"
	"log/slog"
	"os"
	"strings"

	"github.com/chrisdmacrae/com.relirc.core/irc/models"
)

// send sends a raw message to the IRC server
func (c *Client) Send(message string) error {
	_, err := c.conn.Write([]byte(message))
	if err != nil {
		log.Printf("Failed to send message: %v", err)

		return err
	}

	slog.Debug("Sent message", "message", message)

	return nil
}

func (c *Client) JoinChannel(channel string) error {
	c.Channel = channel
	c.State.CurrentChannel = models.Channel{
		Name: channel,
	}

	return c.Send(fmt.Sprintf("JOIN %s\r\n", c.Channel))
}

func (c *Client) SendMessage(channel string, message string) {
	c.Send(fmt.Sprintf("PRIVMSG %s :%s\r\n", channel, message))
}

func (c *Client) RequestAllChannels() {
	c.Send("LIST\r\n")
}

func (c *Client) ReadUserInput() {
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		text := scanner.Text()
		if strings.HasPrefix(text, "/") {
			command := strings.ToUpper(text[1:])
			switch command {
			case "QUIT":
				c.Disconnect()
				return
			}
		} else {
			c.SendMessage(c.State.CurrentChannel.Name, text)
		}
	}

	if err := scanner.Err(); err != nil {
		log.Println("Error reading from stdin:", err)
	}
}
