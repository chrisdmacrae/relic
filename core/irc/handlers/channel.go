package handlers

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
	irc_state "github.com/chrisdmacrae/com.relirc.core/irc/state"
)

var channelConnectRegex = regexp.MustCompile(`^:\S+ JOIN #\S+`)

func onChannelConnect(message string, state *state.ClientState, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 4)

	if len(parts) >= 4 {
		channel := parts[2]

		if channel[0] == '#' {
			state.CurrentChannel.Name = channel

			if channelDelegate != nil {
				channelDelegate.OnConnected(channel)
			}
		} else {
			fmt.Printf("Server: %s\n", channel)
		}
	}
}

var channelDisconnectRegex = regexp.MustCompile(`^:\S+ PART #\S+`)

func onChannelDisconnect(message string, state *state.ClientState, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 4)

	if len(parts) >= 4 {
		channel := parts[2]

		if channel[0] == '#' {
			if channelDelegate != nil {
				channelDelegate.OnDisconnected(channel)
			}
		} else {
			fmt.Printf("Server: %s\n", channel)
		}
	}
}

var channelQuitRegex = regexp.MustCompile(`^:\S+ QUIT`)

func onChannelQuit(message string, state *state.ClientState, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 4)

	if len(parts) >= 4 {
		channel := parts[2]

		if channel[0] == '#' {
			if channelDelegate != nil {
				channelDelegate.OnDisconnected(channel)
			}
		} else {
			fmt.Printf("Server: %s\n", channel)
		}
	}
}

var channelKickRegex = regexp.MustCompile(`^:\S+ KICK #\S+`)

func onChannelKick(message string, state *state.ClientState, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 4)

	if len(parts) >= 4 {
		channel := parts[2]

		if channel[0] == '#' {
			if channelDelegate != nil {
				channelDelegate.OnDisconnected(channel)
			}
		} else {
			fmt.Printf("Server: %s\n", channel)
		}
	}
}

var channelsRegex = regexp.MustCompile(`^:\S+ 322 \S+ \S+ \d+ :`)

func onChannels(message string, state *state.ClientState) {
	parts := strings.SplitN(message, " ", 6)

	if len(parts) >= 6 {
		rawChannelsString := parts[5]

		if rawChannelsString[0] == ':' {
			currentChannels := state.AvailableChannels

			channelNameRegex := regexp.MustCompile(`#(\S+)`)
			newChannels := channelNameRegex.FindAllString(rawChannelsString[1:], -1)
			for _, newChannel := range newChannels {
				exists := false
				for _, currentChannel := range currentChannels {
					if currentChannel == newChannel {
						exists = true
						break
					}
				}

				if !exists {
					currentChannels = append(currentChannels, newChannel)
				}
			}

			state.AvailableChannels = currentChannels
		} else {
			fmt.Printf("Server: %s\n", rawChannelsString)
		}
	} else {
		fmt.Printf("Server: %s\n", message)
	}
}

var channelsEndRegex = regexp.MustCompile(`^:\S+ 323 \S+ :End of (\/)?LIST`)

func onChannelsEnd(message string, state *state.ClientState) {
	irc_state.RequestAllChannelsChan <- state.AvailableChannels
}

var channelNicksRegex = regexp.MustCompile(`^:\S+ 353 \S+ = \S+ :`)

func onChannelNicks(message string, state *state.ClientState) {
	parts := strings.SplitN(message, " ", 6)

	if len(parts) >= 6 {
		channel := parts[4]
		rawUsersString := parts[5]

		if rawUsersString[0] == ':' && channel == state.CurrentChannel.Name {
			nicksString := rawUsersString[1:] // Remove the leading colon from the message
			nickStrings := strings.Split(nicksString, " ")

			state.CurrentChannel.Nicks = nickStrings
		} else {
			fmt.Printf("[%s] Server: %s\n", channel, rawUsersString)
		}
	}
}
