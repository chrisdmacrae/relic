package handlers

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
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

func onChannelDisconnect(message string, channelDelegate delegates.ClientChannelDelegate) {
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

// :<server> 322 <nick> <channel> <user count> :<channel list>
var channelsRegex = regexp.MustCompile(`^:\S+ 322 \S+ \S+ \d+ :\S+`)

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
	state.Chans.RequestAllChannelsChan <- state.AvailableChannels
}

var channelTopicRegex = regexp.MustCompile(`^:\S+ 332 \S+ #\S+ :`)

func onChannelTopic(message string, state *state.ClientState, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 5)

	if len(parts) >= 5 {
		channel := parts[3]
		rawTopicString := parts[4]

		if rawTopicString[0] == ':' && channel == state.CurrentChannel.Name {
			topicString := rawTopicString[1:] // Remove the leading colon from the message

			if state.CurrentChannel.Name == channel {
				state.CurrentChannel.Topic = topicString
			}

			state.Chans.RequestChannelTopicChan <- topicString
		} else {
			fmt.Printf("[%s] Server: %s\n", channel, rawTopicString)
		}
	}
}

var noChannelTopicRegex = regexp.MustCompile(`^:\S+ 331 \S+ #\S+ :No topic is set`)

func onNoChannelTopic(message string, state *state.ClientState) {
	state.CurrentChannel.Topic = ""

	state.Chans.RequestChannelTopicChan <- ""
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

var channelNicksEndRegex = regexp.MustCompile(`^:\S+ 366 \S+ #\S+ :End of /NAMES list`)

func onChannelNicksEnd(message string, state *state.ClientState) {
	state.Chans.RequestChannelUsersChan <- state.CurrentChannel.Nicks
}

var onChannelUsersRegex = regexp.MustCompile(`^:\S+ 352 \S+ \S+ \S+ \S+ \S+ :`)

func onChannelUsers(message string, state *state.ClientState) {
	parts := strings.SplitN(message, " ", 8)

	if len(parts) >= 8 {
		channel := parts[4]
		rawUsersString := parts[7]

		if rawUsersString[0] == ':' && channel == state.CurrentChannel.Name {
			usersString := rawUsersString[1:] // Remove the leading colon from the message
			userStrings := strings.Split(usersString, " ")

			for _, userString := range userStrings {
				found := false
				for _, nick := range state.CurrentChannel.Nicks {
					if nick == userString {
						found = true
						break
					}
				}

				if !found {
					state.CurrentChannel.Nicks = append(state.CurrentChannel.Nicks, userString)
				}
			}

			state.Chans.RequestChannelUsersChan <- userStrings
		} else {
			fmt.Printf("[%s] Server: %s\n", channel, rawUsersString)
		}
	}
}
