package objc

import (
	"encoding/json"
	"log/slog"
	"strings"
	"time"

	"github.com/chrisdmacrae/com.relirc.core/irc"
	"github.com/chrisdmacrae/com.relirc.core/irc/config"
	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/dtos"
	"github.com/chrisdmacrae/com.relirc.core/irc/models"
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
	GetChannelPayload(name string) string
	GetUserPayload(nick string) string

	PinChannel(channel string) error
	UnpinChannel(channel string) error
	JoinChannel(channel string) error
	SendMessage(channel string, message string)
}

func NewIrcBridge() IrcBridge {
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
		return string(payload[len(payload)-10:])
	}

	return string(payload)
}

func (b *ircBridge) GetAvailableChannelsPayload() string {
	b.client.RequestAllChannels()

	// wait for state from channel;
	<-b.client.State.Chans.RequestAllChannelsChan

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

func (b *ircBridge) GetChannelPayload(name string) string {
	slog.Debug("irc", "waiting for channel state", name)

	b.client.RequestChannelTopic(name)
	var topic string = ""
	select {
	case topic := <-b.client.State.Chans.RequestChannelTopicChan:
		slog.Debug("irc", "got channel topic", topic)
	case <-time.After(5 * time.Second):
		slog.Debug("irc", "timeout waiting for channel topic")
		break
	}

	b.client.RequestChannelUsers(name)
	var nicks []string = []string{}
	select {
	case nicks = <-b.client.State.Chans.RequestChannelUsersChan:
		slog.Debug("irc", "got channel nicks", nicks)
	case <-time.After(5 * time.Second):
		slog.Debug("irc", "timeout waiting for channel users")
		break
	}

	isPinned := false
	pinnedChannels, err := config.GetPinnedChannels(b.client.State.CurrentServer.Hostname)
	if err != nil {
		slog.Debug("irc", "error", err)
	} else {
		for _, channel := range pinnedChannels {
			if channel == name {
				isPinned = true
				break
			}
		}
	}

	channel := dtos.Channel{
		Name:                name,
		Topic:               topic,
		IsPinned:            isPinned,
		NicksCommaDelimited: strings.Join(nicks, ","),
	}

	payload, err := json.Marshal(channel)
	if err != nil {
		slog.Info("irc", "error", err)
		return "{}"
	}

	return string(payload)
}

func (b *ircBridge) GetUserPayload(nick string) string {
	b.client.RequestUserWhois(nick)

	var whois *models.User
	for whois == nil {
		current_nick := <-b.client.State.Chans.RequestUserWhoisChan

		if current_nick == nick {
			user := b.client.State.Users[nick]

			whois = &user
		}
	}

	payload, err := json.Marshal(whois)
	if err != nil {
		slog.Info("irc", "error", err)
		return "[]"
	}

	return string(payload)
}

func (b *ircBridge) SetConnectionDelegate(delegate delegates.ClientConnectionDelegate) {
	slog.Debug("irc", "SetConnectionDelegate", delegate)

	b.client.ConnectionDelegate = delegate
}

func (b *ircBridge) SetChannelDelegate(delegate delegates.ClientChannelDelegate) {
	slog.Debug("irc", "SetChannelDelegate", delegate)

	b.client.ChannelDelegate = delegate
}

func (b *ircBridge) Disconnect() {
	b.client.Disconnect()
}
