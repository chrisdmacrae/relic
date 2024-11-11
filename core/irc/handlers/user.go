package handlers

import (
	"log/slog"
	"regexp"
	"strings"

	"github.com/chrisdmacrae/com.relirc.core/irc/enums"
	"github.com/chrisdmacrae/com.relirc.core/irc/models"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
)

var userHostRegex = regexp.MustCompile(`^:\S+ 352 \S+ \S+ \S+ \S+ \S+ \S+ \S+ :`)

func onUserHost(message string, state *state.ClientState) {
	const userHostPrefix = "302"

	// Check if message has the correct prefix for USERHOST response
	if !strings.Contains(message, userHostPrefix) {
		slog.Error("message does not contain USERHOST prefix")
		return
	}

	// Extract the actual user information part
	parts := strings.SplitN(message, ":", 3)
	if len(parts) < 3 {
		slog.Error("message does not contain user information")
		return
	}

	// Get the first user data (assuming it's for a single nickname)
	userData := strings.Split(parts[2], " ")[0]
	if userData == "" {
		slog.Warn("no user data found")
		return
	}

	nicknameEnd := strings.IndexAny(userData, "=+-")
	if nicknameEnd == -1 {
		slog.Warn("invalid user data format")
		return
	}

	nickname := userData[:nicknameEnd]
	statusSymbol := userData[nicknameEnd : nicknameEnd+1]
	host := userData[nicknameEnd+1:]

	var status enums.UserStatus
	switch statusSymbol {
	case "=":
		status = enums.UserOnline
	case "*":
		status = enums.UserOperator
	case "+":
		status = enums.UserAway
	case "-":
		status = enums.UserAway
	default:
		status = enums.UserUnknown
	}

	if state.CurrentUser.Nick == nickname {
		state.CurrentUser.Host = host
		state.CurrentUser.Status = enums.UserStatus(status)
	}
}

var whoisRegex = regexp.MustCompile(`^:\S+ 311 \S+ \S+ \S+ \S+ :`)

func onWhois(message string, state *state.ClientState) {
	parts := strings.SplitN(message, " ", 6)

	if len(parts) >= 6 {
		nick := parts[2]
		username := parts[3]
		host := parts[4]
		realName := parts[5]

		if state.CurrentUser.Nick == nick {
			state.CurrentUser.Username = username
			state.CurrentUser.Host = host
			state.CurrentUser.RealName = realName
		}

		channelUser := state.CurrentChannel.GetUser(nick)
		if channelUser != nil {
			channelUser.Username = username
			channelUser.Host = host
			channelUser.RealName = realName
		}
	}
}

var nickChanegdRegex = regexp.MustCompile(`^:\S+ NICK :`)

func onNickChanged(message string, channel *models.Channel) {
	parts := strings.SplitN(message, " ", 6)

	if len(parts) >= 6 {
		oldNick := parts[0]
		newNick := parts[2]

		channel.UpdateOrAddUser(newNick, &models.User{
			Nick: newNick,
			Host: channel.GetUser(oldNick).Host,
		})

		channel.RemoveUser(oldNick)
	}
}
