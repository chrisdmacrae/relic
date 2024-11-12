package models

import "time"

type Message struct {
	Channel   string
	Nick      string
	Text      string
	Timestamp int64
}

func NewMessage(channel, nick, text string) *Message {
	return &Message{
		Channel:   channel,
		Nick:      nick,
		Text:      text,
		Timestamp: time.Now().Unix(),
	}
}
