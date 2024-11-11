package delegates

type ClientChannelDelegate interface {
	OnConnected(channel string)
	OnDisconnected(channel string)
	OnMessageReceived(channel string, nick string, text string)
}
