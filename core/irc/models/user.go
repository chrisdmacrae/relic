package models

import (
	"fmt"

	"github.com/chrisdmacrae/com.relirc.core/irc/dtos"
	"github.com/chrisdmacrae/com.relirc.core/irc/enums"
)

type User struct {
	Nick     string           `json:"nick"`
	Username string           `json:"username"`
	RealName string           `json:"realname"`
	Status   enums.UserStatus `json:"status"`
	Channels []string         `json:"channels"`
	Host     string           `json:"host"`
	Hopcount int              `json:"-"`
}

func (u *User) ToDto() dtos.User {
	return dtos.User{
		Nick:     u.Nick,
		RealName: u.RealName,
		Host:     u.Host,
		Status:   u.Status,
	}
}

type UserWhois struct {
	User
	Channels []string `json:"channels"`
}

// <username> <hostname> <servername> <realname>
func (u *User) UserInfo() string {
	return fmt.Sprintf("%s %d %s :%s", u.Username, u.Hopcount, "*", u.RealName)
}
