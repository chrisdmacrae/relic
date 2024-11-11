package models

import "encoding/json"

type Server struct {
	Hostname       string   `json:"hostname"`
	Port           int      `json:"port"`
	Nickname       string   `json:"nickname"`
	Realname       string   `json:"realname"`
	Username       *string  `json:"username"`
	Password       *string  `json:"password"`
	PinnedChannels []string `json:"pinned_channels"`
}

func (s *Server) ToJson() (string, error) {
	data, err := json.Marshal(s)
	if err != nil {
		return "", err
	}

	return string(data), nil
}
