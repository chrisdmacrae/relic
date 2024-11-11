package models

import (
	"github.com/chrisdmacrae/com.relirc.core/irc/dtos"
	"github.com/chrisdmacrae/com.relirc.core/irc/enums"
)

type Channel struct {
	Name     string
	Nicks    []string
	messages []Message
	users    map[string]*User

	// Callbacks
	OnUser func(nick string, user dtos.User)
}

func (c *Channel) AddMessage(message Message) {
	c.messages = append(c.messages, message)
}

func (c *Channel) GetUser(nick string) *User {
	return c.users[nick]
}

func (c *Channel) UpdateOrAddUser(nick string, user *User) {
	if existingUser, ok := c.users[nick]; ok {
		if user.Username != "" {
			existingUser.Username = user.Username
		}

		if user.RealName != "" {
			existingUser.RealName = user.RealName
		}

		if user.Host != "" {
			existingUser.Host = user.Host
		}

		if user.Status != enums.UserUnknown {
			existingUser.Status = user.Status
		}
	} else {
		c.users[nick] = user
	}
}

func (c *Channel) RemoveUser(nick string) {
	delete(c.users, nick)
}

func (c *Channel) GetUserSafe(nick string) *dtos.User {
	user := c.users[nick]

	if user == nil {
		return nil
	}

	return &dtos.User{
		Nick:     user.Nick,
		Username: user.Username,
		RealName: user.RealName,
		Host:     user.Host,
		Status:   user.Status,
	}
}

func (c *Channel) GetMessages() []Message {
	return c.messages
}
