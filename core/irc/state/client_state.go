package state

import "github.com/chrisdmacrae/com.relirc.core/irc/models"

type ClientState struct {
	CurrentServer     *models.Server
	CurrentUser       *models.User
	CurrentChannel    *models.Channel
	Users             map[string]models.User
	AvailableChannels []string
	Chans             ClientChannels
}

func NewClientState() ClientState {
	return ClientState{
		Chans: NewClientChannels(),
	}
}

type ClientChannels struct {
	ServerPongChan          chan bool
	ConnectedChan           chan bool
	RequestAllChannelsChan  chan []string
	RequestChannelTopicChan chan string
	RequestChannelUsersChan chan []string
	RequestUserWhoisChan    chan string
}

func NewClientChannels() ClientChannels {
	return ClientChannels{
		ServerPongChan:          make(chan bool, 1),
		ConnectedChan:           make(chan bool, 1),
		RequestAllChannelsChan:  make(chan []string, 1),
		RequestChannelTopicChan: make(chan string, 1),
		RequestChannelUsersChan: make(chan []string, 1),
		RequestUserWhoisChan:    make(chan string, 1),
	}
}
