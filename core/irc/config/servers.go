package config

import (
	"errors"

	"github.com/chrisdmacrae/com.relirc.core/config"
	"github.com/chrisdmacrae/com.relirc.core/irc/models"
)

func GetServers() ([]models.Server, error) {
	servers, err := config.Get[[]models.Server]("servers")
	if err != nil {
		return nil, err
	}

	return *servers, nil
}

func AddOrUpdateServer(server models.Server) error {
	servers, err := GetServers()
	if errors.Is(err, config.ErrKeyNotFound) {
		servers = []models.Server{}
	} else if err != nil {
		return err
	}

	if servers == nil {
		servers = []models.Server{}
	}

	var existingServer *models.Server
	var existingServerIndex int
	for i, s := range servers {
		if s.Hostname == server.Hostname {
			existingServer = &s
			existingServerIndex = i
			break
		}
	}

	if existingServer != nil {
		existingServer.Nickname = server.Nickname
		existingServer.Realname = server.Realname
		existingServer.Username = server.Username
		existingServer.Password = server.Password

		servers[existingServerIndex] = *existingServer

		return config.Set("servers", servers)
	} else {
		servers = append(servers, server)

		return config.Set("servers", servers)
	}
}

func GetPinnedChannels(hostname string) ([]string, error) {
	servers, err := GetServers()
	if err != nil {
		return nil, err
	}

	for _, s := range servers {
		if s.Hostname == hostname {
			return s.PinnedChannels, nil
		}
	}

	return nil, nil
}

func PinChannel(hostname string, channel string) error {
	servers, err := GetServers()
	if err != nil {
		return err
	}

	for i, s := range servers {
		if s.Hostname == hostname {
			if s.PinnedChannels == nil {
				s.PinnedChannels = []string{}
			}

			// check if already pinned
			for _, c := range s.PinnedChannels {
				if c == channel {
					return nil
				}
			}

			servers[i].PinnedChannels = append(s.PinnedChannels, channel)

			return config.Set("servers", servers)
		}
	}

	return nil
}

func UnpinChannel(hostname string, channel string) error {
	servers, err := GetServers()
	if err != nil {
		return err
	}

	for i, s := range servers {
		if s.Hostname == hostname {
			if s.PinnedChannels == nil {
				s.PinnedChannels = []string{}
			}

			for j, c := range s.PinnedChannels {
				if c == channel {
					s.PinnedChannels = append(s.PinnedChannels[:j], s.PinnedChannels[j+1:]...)
					servers[i].PinnedChannels = s.PinnedChannels

					return config.Set("servers", servers)
				}
			}
		}
	}

	return nil
}
