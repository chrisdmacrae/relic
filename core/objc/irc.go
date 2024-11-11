package objc

import (
	"encoding/json"
	"log/slog"
	"time"

	"github.com/chrisdmacrae/com.relirc.core/irc"
	"github.com/chrisdmacrae/com.relirc.core/irc/config"
	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
)

type IrcBridge interface {
	Connect(server string, port int, nick string, realname string) error
	ConnectWithAuth(server string, port int, nickname string, realname string, username string, password string) error
	StartBackgroundHealthcheck()
	Disconnect()
	IsConnected() bool

	SetConnectionDelegate(delegate delegates.ClientConnectionDelegate)
	SetChannelDelegate(delegate delegates.ClientChannelDelegate)

	GetRecentServersPayload() string
	GetAvailableChannelsPayload() string
	GetPinnedChannelsPayload() string

	PinChannel(channel string) error
	UnpinChannel(channel string) error
	JoinChannel(channel string) error
	SendMessage(channel string, message string)
}

func NewBridge() IrcBridge {
	slog.SetLogLoggerLevel(slog.LevelDebug)

	return &ircBridge{
		client: irc.NewClient(),
	}
}

type ircBridge struct {
	client *irc.Client
}

func (b *ircBridge) StartBackgroundHealthcheck() {
	for {
		b.client.Healthcheck()

		<-time.After(1 * time.Second)
	}
}

func (b *ircBridge) Connect(server string, port int, nick string, realname string) error {
	return b.client.Connect(server, port, nick, realname, &nick, nil)
}

func (b *ircBridge) ConnectWithAuth(server string, port int, nick string, realname string, username string, password string) error {
	return b.client.Connect(server, port, nick, realname, &username, &password)
}

func (b *ircBridge) IsConnected() bool {
	return b.client.IsConnected()
}

func (b *ircBridge) JoinChannel(channel string) error {
	return b.client.JoinChannel(channel)
}

func (b *ircBridge) SendMessage(channel string, message string) {
	if message[0] == '/' {
		b.client.Send(message)
	} else {
		b.client.SendMessage(channel, message)
	}
}

func (b *ircBridge) PinChannel(channel string) error {
	return config.PinChannel(b.client.State.CurrentServer.Hostname, channel)
}

func (b *ircBridge) UnpinChannel(channel string) error {
	return config.UnpinChannel(b.client.State.CurrentServer.Hostname, channel)
}

func (b *ircBridge) GetRecentServersPayload() string {
	servers, err := config.GetServers()
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	payload, err := json.Marshal(servers)
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	// return last 10
	if len(servers) > 10 {
		// return string(payload[len(payload)-10:])
	}

	return string(payload)
}

func (b *ircBridge) GetAvailableChannelsPayload() string {
	b.client.RequestAllChannels()

	// wait for state from channel;
	<-state.RequestAllChannelsChan

	payload, err := json.Marshal(b.client.State.AvailableChannels)
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	return string(payload)
}

func (b *ircBridge) GetPinnedChannelsPayload() string {
	channels, err := config.GetPinnedChannels(b.client.State.CurrentServer.Hostname)
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	payload, err := json.Marshal(channels)
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	return string(payload)
}

func (b *ircBridge) SetConnectionDelegate(delegate delegates.ClientConnectionDelegate) {
	b.client.ConnectionDelegate = delegate
}

func (b *ircBridge) SetChannelDelegate(delegate delegates.ClientChannelDelegate) {
	b.client.ChannelDelegate = delegate
}

func (b *ircBridge) Disconnect() {
	b.client.Disconnect()
}
