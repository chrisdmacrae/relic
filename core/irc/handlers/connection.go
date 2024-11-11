package handlers

import (
	"regexp"

	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
)

var connectedRegex = regexp.MustCompile(`^:(.*) 001 (.*) (.*)$`)

func onConnectedMessage(message string, connectionDelegate delegates.ClientConnectionDelegate) {
	state.ConnectedChan <- true

	if connectionDelegate != nil {
		connectionDelegate.OnConnected()
	}
}

var noticeRegex = regexp.MustCompile(`^:(.*) NOTICE (.*) :(.*)$`)

func onNoticeMessage(message string, connectionDelegate delegates.ClientConnectionDelegate) {
	// parse the notice from the message
	matches := noticeRegex.FindStringSubmatch(message)
	notice := matches[3]

	if connectionDelegate != nil {
		connectionDelegate.OnNotice(notice)
	}
}
