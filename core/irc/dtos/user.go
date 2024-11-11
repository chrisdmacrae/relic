package dtos

import (
	"encoding/json"

	"github.com/chrisdmacrae/com.relirc.core/irc/enums"
)

type User struct {
	Nick     string           `json:"nick"`
	Username string           `json:"username"`
	RealName string           `json:"realname"`
	Host     string           `json:"host"`
	Status   enums.UserStatus `json:"online"`
}

func (u *User) ToJson() (string, error) {
	json, err := json.Marshal(u)

	if err != nil {
		return "", err
	}

	return string(json), nil
}

func UserFromJson(payload string) (User, error) {
	var user User
	err := json.Unmarshal([]byte(payload), &user)

	if err != nil {
		return User{}, err
	}

	return user, nil
}
