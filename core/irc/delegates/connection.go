package delegates

type ClientConnectionDelegate interface {
	OnConnected()
	OnDisconnected()
	OnNotice(message string)
}
