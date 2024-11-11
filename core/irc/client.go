package irc

import (
	"bufio"
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"log"
	"net"
	"strings"
	"time"

	"github.com/chrisdmacrae/com.relirc.core/irc/config"
	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/handlers"
	"github.com/chrisdmacrae/com.relirc.core/irc/models"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
)

// Client represents an IRC client
type Client struct {
	Server   string
	Channel  string
	State    state.ClientState
	lastPing int64
	conn     net.Conn

	// Delegates
	ConnectionDelegate delegates.ClientConnectionDelegate
	ChannelDelegate    delegates.ClientChannelDelegate
}

type IrcHandlers interface {
	OnPrivMsg(message string)
	OnNickChanged(message string, state state.ClientState)
	OnUserHost(message string)
	OnWhois(message string)
	OnChannelNicks(message string, state state.ClientState)
}

// NewClient initializes a new IRC client
func NewClient() *Client {
	return &Client{
		State: state.ClientState{},
	}
}

func (c *Client) Connect(hostname string, port int, nick string, realname string, password *string) error {
	c.Server = fmt.Sprintf("%s:%d", hostname, port)

	c.State.CurrentServer = models.Server{
		Hostname: hostname,
		Port:     port,
		Nickname: nick,
		Realname: realname,
		Username: &nick,
		Password: password,
	}

	c.State.CurrentUser = models.User{
		Nick:     nick,
		RealName: realname,
	}

	err := config.AddServer(models.Server{
		Hostname: hostname,
		Port:     port,
		Nickname: nick,
		Realname: realname,
		Username: &nick,
		Password: password,
	})
	if err != nil {
		return fmt.Errorf("failed to add server to config: %w", err)
	}

	conn, err := tls.Dial("tcp", c.Server, &tls.Config{})
	if err != nil {
		return fmt.Errorf("failed to connect to IRC server: %w", err)
	}
	c.conn = conn

	if password != nil {
		c.Send("CAP REQ :sasl\r\n")
		c.Send(fmt.Sprintf("NICK %s\r\n", c.State.CurrentUser.Nick))
		c.Send(fmt.Sprintf("USER %s\r\n", c.State.CurrentUser.UserInfo()))

		// Handle SASL authentication
		c.Send("AUTHENTICATE PLAIN\r\n")
		authString := fmt.Sprintf("%s\x00%s\x00%s", c.State.CurrentUser.Username, c.State.CurrentUser.Username, *password)
		encodedAuth := base64.StdEncoding.EncodeToString([]byte(authString))
		c.Send(fmt.Sprintf("AUTHENTICATE %s\r\n", encodedAuth))
		c.Send("CAP END\r\n")
	} else {
		c.Send(fmt.Sprintf("NICK %s\r\n", c.State.CurrentUser.Nick))
		c.Send(fmt.Sprintf("USER %s\r\n", c.State.CurrentUser.UserInfo()))
	}

	go c.handleServerMessages()

	connected := <-state.ConnectedChan

	if !connected {
		return fmt.Errorf("failed to connect")
	}

	c.lastPing = time.Now().Unix()

	return nil
}

func (c *Client) IsConnected() bool {
	didSend := testConnWithPing(c.conn)

	return c.conn != nil && time.Now().Unix()-c.lastPing <= 300 && didSend
}

// Disconnect closes the connection to the IRC server
func (c *Client) Disconnect() {
	if c.conn != nil {
		c.Send("QUIT\r\n")
		c.Send("DISCONNECT\r\n")

		go func() {
			for c.IsConnected() {
				time.Sleep(1 * time.Second)
			}

			c.conn.Close()
			c.conn = nil

			if c.ConnectionDelegate != nil {
				c.ConnectionDelegate.OnDisconnected()
			}
		}()

	}
}

func (c *Client) Healthcheck() {
	if c.conn == nil {
		return
	}

	if !c.IsConnected() {
		if c.ConnectionDelegate != nil {
			c.ConnectionDelegate.OnDisconnected()
		}
	}

	if time.Now().Unix()-c.lastPing > int64(5*time.Second) {
		c.Disconnect()
	}
}

// handleServerMessages listens for messages from the IRC server and processes user messages
func (c *Client) handleServerMessages() {
	reader := bufio.NewReader(c.conn)
	for {
		if c.conn == nil {
			return
		}

		message, err := reader.ReadString('\n')
		if err != nil {
			log.Println("Error reading from server:", err)
			return
		}
		message = strings.TrimSpace(message)

		// Handle PING from server to keep the connection alive
		if strings.HasPrefix(message, "PING") {
			c.lastPing = time.Now().Unix()
			pongResponse := "PONG " + message[5:]
			c.Send(pongResponse)
			continue
		}

		// Handle PONG from server
		if strings.HasPrefix(message, "PONG") {
			state.ServerPongChan <- true
			continue
		}

		handlers.HandleMessage(message, handlers.HandleMessageDependencies{
			ChannelDelegate:    c.ChannelDelegate,
			ConnectionDelegate: c.ConnectionDelegate,
			State:              &c.State,
		})
	}
}

func testConnWithPing(conn net.Conn) bool {
	if conn == nil {
		return false
	}

	_, err := conn.Write([]byte("PING :test\r\n"))
	if err != nil {
		log.Println("Error writing to server:", err)
		return false
	}

	return <-state.ServerPongChan
}