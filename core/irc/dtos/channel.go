package dtos

import "encoding/json"

type Channel struct {
	Name string
}

func (c *Channel) ToJson() (string, error) {
	json, err := json.Marshal(c)

	if err != nil {
		return "", err
	}

	return string(json), nil
}

func ChannelFromJson(payload string) (Channel, error) {
	var channel Channel
	err := json.Unmarshal([]byte(payload), &channel)

	if err != nil {
		return Channel{}, err
	}

	return channel, nil
}
