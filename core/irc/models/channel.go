package models

type Channel struct {
	Name     string
	Topic    string
	Nicks    []string
	messages []Message
}

func (c *Channel) AddMessage(message Message) {
	c.messages = append(c.messages, message)
}

func (c *Channel) GetMessages() []Message {
	return c.messages
}
