package handlers

import (
	"fmt"

	"github.com/chrisdmacrae/com.relirc.core/irc/delegates"
	"github.com/chrisdmacrae/com.relirc.core/irc/state"
)

type HandleMessageDependencies struct {
	ChannelDelegate    delegates.ClientChannelDelegate
	ConnectionDelegate delegates.ClientConnectionDelegate
	State              *state.ClientState
}

func HandleMessage(message string, deps HandleMessageDependencies) {
	// Log all server messages to console
	fmt.Println(message)

	switch {
	case connectedRegex.MatchString(message):
		onConnectedMessage(message, deps.ConnectionDelegate, deps.State)
	case noticeRegex.MatchString(message):
		onNoticeMessage(message, deps.ConnectionDelegate)
	case privMsgRegex.MatchString(message):
		onPrivMsg(message, deps.ChannelDelegate)
	case onChannelUsersRegex.MatchString(message):
		onChannelUsers(message, deps.State)
	case channelNicksRegex.MatchString(message):
		onChannelNicks(message, deps.State)
	case channelNicksEndRegex.MatchString(message):
		onChannelNicksEnd(message, deps.State)
	case channelsRegex.MatchString(message):
		onChannels(message, deps.State)
	case channelsEndRegex.MatchString(message):
		onChannelsEnd(message, deps.State)
	case channelConnectRegex.MatchString(message):
		onChannelConnect(message, deps.State, deps.ChannelDelegate)
	case channelDisconnectRegex.MatchString(message):
		onChannelDisconnect(message, deps.ChannelDelegate)
	case channelQuitRegex.MatchString(message):
		onChannelQuit(message, deps.State, deps.ChannelDelegate)
	case userHostRegex.MatchString(message):
		onUserHost(message, deps.State)
	case whoisBasicRegex.MatchString(message):
		onWhoisBasicInfo(message, deps.State)
	case whoisChannelsRegex.MatchString(message):
		onWhoisChannels(message, deps.State)
	case whoisRealNameRegex.MatchString(message):
		onWhoisRealName(message, deps.State)
	case whoisEndRegex.MatchString(message):
		onWhoisEnd(message, deps.State)
	default:
		return
	}
}
