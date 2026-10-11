SCHEME := BARTist
PROJECT := BARTist.xcodeproj
BUNDLE := app.bartist
SIMULATOR ?= iPhone 17
DESTINATION := platform=iOS Simulator,name=$(SIMULATOR)
DERIVED := .derived
APP := $(DERIVED)/Build/Products/Debug-iphonesimulator/BARTist.app

.DEFAULT_GOAL := help

.PHONY: help generate open build run simulators

help:
	@echo "make generate     regenerate $(PROJECT) from project.yml"
	@echo "make open         open the project in Xcode"
	@echo "make build        build for the iOS Simulator ($(SIMULATOR))"
	@echo "make run          build, boot that simulator, install, and launch"
	@echo "make simulators   list available simulators"
	@echo ""
	@echo "SIMULATOR='iPhone 17 Pro iOS 26.5' make run"

generate:
	xcodegen generate --spec project.yml

open: generate
	open $(PROJECT)

build: generate
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED) \
		-configuration Debug \
		build

run: build
	open -a Simulator
	xcrun simctl boot "$(SIMULATOR)" || true
	xcrun simctl bootstatus "$(SIMULATOR)" -b
	xcrun simctl install booted "$(APP)"
	xcrun simctl launch booted $(BUNDLE)

simulators:
	xcrun simctl list devices available
