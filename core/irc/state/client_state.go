package state

import "github.com/chrisdmacrae/com.relirc.core/irc/models"

type ClientState struct {
	ChannelNames      []string
	CurrentServer     models.Server
	CurrentUser       models.User
	CurrentChannel    models.Channel
	AvailableChannels []string
}

var ServerPongChan = make(chan bool)
var ConnectedChan = make(chan bool)
var RequestAllChannelsChan = make(chan []string)
var RequestAllUsersChan = make(chan string)
