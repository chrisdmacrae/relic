package dtos

import "encoding/json"

type Server struct {
	Hostname string
	Port     int
	Nickname string
	Realname string
	Password string
}

func (s *Server) ToJson() (string, error) {
	json, err := json.Marshal(s)

	if err != nil {
		return "", err
	}

	return string(json), nil
}

func ServerFromJson(payload string) (Server, error) {
	var server Server
	err := json.Unmarshal([]byte(payload), &server)

	if err != nil {
		return Server{}, err
	}

	return server, nil
}
