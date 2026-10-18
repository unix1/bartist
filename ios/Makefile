SCHEME := BARTist
PROJECT := BARTist.xcodeproj
BUNDLE := app.bartist
SIMULATOR ?= iPhone 17
# xcodebuild defaults to OS=latest (26.5 here). Older sims need OS= set.
ifeq ($(OS),)
DESTINATION := platform=iOS Simulator,name=$(SIMULATOR)
else
DESTINATION := platform=iOS Simulator,name=$(SIMULATOR),OS=$(OS)
endif
DERIVED := .derived
APP := $(DERIVED)/Build/Products/Debug-iphonesimulator/BARTist.app

.DEFAULT_GOAL := help

.PHONY: help generate open build run test simulators screenshots

help:
	@echo "make generate     regenerate $(PROJECT) from project.yml"
	@echo "make open         open the project in Xcode"
	@echo "make build        build for the iOS Simulator ($(SIMULATOR))"
	@echo "make run          build, boot that simulator, install, and launch"
	@echo "make test         run unit tests (BARTistTests)"
	@echo "make simulators   list available simulators"
	@echo "make screenshots  capture Fastlane screenshots"
	@echo ""
	@echo "SIMULATOR='iPhone 16' OS=18.6 make run"

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

test: generate
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED) \
		-only-testing:BARTistTests \
		CODE_SIGNING_ALLOWED=NO \
		test

screenshots: generate
	fastlane screenshots

simulators:
	xcrun simctl list devices available
