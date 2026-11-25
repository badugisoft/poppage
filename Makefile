APP_NAME := PopPage
APP_BUNDLE := build/$(APP_NAME).app
INSTALL_DIR ?= /Applications
INSTALLED_APP := $(INSTALL_DIR)/$(APP_NAME).app

.DEFAULT_GOAL := help
.PHONY: help build release icon lint app run install uninstall clean

help:
	@echo "Available targets:"
	@echo "  make build      - Build debug binary (swift build)"
	@echo "  make release    - Build release binary (swift build -c release)"
	@echo "  make icon       - Regenerate Resources/AppIcon.icns"
	@echo "  make lint       - Validate Info.plist and Localizable.strings"
	@echo "  make app        - Build release .app bundle ($(APP_BUNDLE))"
	@echo "  make run        - Build .app bundle and launch $(APP_NAME)"
	@echo "  make install    - Install $(APP_NAME).app to $(INSTALL_DIR)"
	@echo "  make uninstall  - Remove $(APP_NAME).app from $(INSTALL_DIR)"
	@echo "  make clean      - Remove .build and build directories"

build:
	swift build

release:
	swift build -c release

icon:
	swift scripts/generate-icon.swift

lint:
	plutil -lint Resources/Info.plist Resources/Localization/*.lproj/Localizable.strings

app:
	chmod +x scripts/build-app.sh
	./scripts/build-app.sh

run: app
	pkill -x $(APP_NAME) || true
	sleep 0.5
	open "$(APP_BUNDLE)"

install: app
	pkill -x $(APP_NAME) || true
	rm -rf "$(INSTALLED_APP)"
	cp -R "$(APP_BUNDLE)" "$(INSTALL_DIR)/"
	@echo "Installed $(INSTALLED_APP)"

uninstall:
	pkill -x $(APP_NAME) || true
	rm -rf "$(INSTALLED_APP)"
	@echo "Uninstalled $(INSTALLED_APP)"

clean:
	rm -rf .build build
