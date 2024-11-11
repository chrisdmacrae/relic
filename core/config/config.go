package config

import (
	"encoding/json"
	"errors"
	"io"
	"os"
)

var ErrKeyNotFound = errors.New("key not found")

func Set(key string, value interface{}) error {
	contents, err := load()
	if err != nil {
		return err
	}

	existingKeyValuePairs := map[string]interface{}{}
	if contents != "" {
		json.Unmarshal([]byte(contents), &existingKeyValuePairs)
	}

	existingKeyValuePairs[key] = value

	newContents, err := json.Marshal(existingKeyValuePairs)
	if err != nil {
		return err
	}

	err = write(string(newContents))
	if err != nil {
		return err
	}

	return nil
}

func Get[T any](key string) (*T, error) {
	contents, err := load()
	if err != nil {
		return nil, err
	}

	keyValuePairs := map[string]interface{}{}
	if contents != "" {
		err := json.Unmarshal([]byte(contents), &keyValuePairs)
		if err != nil {
			return nil, err
		}
	}

	// Check if the key exists in the map
	rawValue, exists := keyValuePairs[key]
	if !exists {
		return nil, ErrKeyNotFound
	}

	rawValueBytes, err := json.Marshal(rawValue)
	if err != nil {
		return nil, err
	}

	var returnValue T
	err = json.Unmarshal(rawValueBytes, &returnValue)
	if err != nil {
		return nil, err
	}

	return &returnValue, nil
}

func load() (string, error) {
	configFile, err := configPath()
	if err != nil {
		return "", err
	}

	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		return "", nil
	}

	file, err := os.OpenFile(configFile, os.O_RDONLY, 0644)
	if err != nil {
		return "", err
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		return "", err
	}

	return string(content), nil
}

func write(json string) error {
	configDir, err := configDir()
	if err != nil {
		return err
	}

	if _, err := os.Stat(configDir); os.IsNotExist(err) {
		os.Mkdir(configDir, 0755)
	}

	configFile, err := configPath()
	if err != nil {
		return err
	}

	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		_, err := os.Create(configFile)
		if err != nil {
			return err
		}
	}

	file, err := os.OpenFile(configFile, os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.WriteString(json)
	if err != nil {
		return err
	}

	return nil
}

func configDir() (string, error) {
	dirname, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	return dirname + "/.relirc", nil
}

func configPath() (string, error) {
	dirname, err := configDir()
	if err != nil {
		return "", err
	}

	return dirname + "/config.json", nil
}
