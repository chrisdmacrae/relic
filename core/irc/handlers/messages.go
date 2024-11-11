package handlers

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
)

var privMsgRegex = regexp.MustCompile(`^:\S+ PRIVMSG \S+ :`)

func onPrivMsg(message string, channelDelegate delegates.ClientChannelDelegate) {
	parts := strings.SplitN(message, " ", 4)

	if len(parts) >= 4 {
		// Extract sender nickname
		sender := strings.SplitN(parts[0], "!", 2)[0][1:]
		channel := parts[2]
		text := parts[3][1:] // Remove the leading colon from the message

		if channelDelegate != nil {
			channelDelegate.OnMessageReceived(channel, sender, text)
		} else {
			fmt.Printf("[%s] %s: %s\n", channel, sender, text)
		}
	}
}
