.PHONY: install
install:
	go install golang.org/x/mobile/cmd/gomobile@latest
	gomobile init

.PHONY: macos
macos:
	gomobile bind -v -target macos -o ./build/macos/core.xcframework ./objc/... ./irc/...