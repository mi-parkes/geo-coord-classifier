.ONESHELL:
SHELL           =/bin/bash
.SHELLFLAGS 	= -e -c
MAKEFLAGS       += $(if $(VERBOSE),,--no-print-directory)
MINMAKEVERSION  =3.82
$(if $(findstring $(MINMAKEVERSION),$(firstword $(sort $(MINMAKEVERSION) $(MAKE_VERSION)))),,$(error The Makefile requires minimal GNU make version:$(MINMAKEVERSION) and you are using:$(MAKE_VERSION)))

BUILD_CONFIGURATION = Debug
ARCHS = arm64
PROJECTDIR = geoCoordClassifier.xcodeproj
XCODEBUILD = arch -arm64e xcodebuild
UTILS ?= ../utils.mak

.PHONY: clean help

$(MAKE_VERBOSE).SILENT:
	echo NothingAtAll

help:
	echo $(MAKE) help
	echo $(MAKE) clean
	echo $(MAKE) build-macosx
	echo $(MAKE) run-macosx
	echo $(MAKE) build-cli-macosx
	echo $(MAKE) run-cli-macosx
	echo $(MAKE) test-geoCoordClassifierCore
	echo $(MAKE) build-ios-iphonesimulator
	echo $(MAKE) start-simulator
	echo $(MAKE) run-app-in-ios-simulator
	echo $(MAKE) build-iphoneos

targets:
	$(XCODEBUILD) -list -project $(PROJECTDIR)

sdks:
	$(XCODEBUILD) -showsdks

destinations:
	$(eval SCHEME=classifier)
	$(XCODEBUILD)  -project $(PROJECTDIR) \
		-scheme $(SCHEME) -showdestinations

clean:
	rm -rf DerivedData
	rm -rf Build
	rm -rf $(PROJECTDIR)/xcuserdata
	rm -rf $(PROJECTDIR)/project.xcworkspace/xcuserdata
	rm -rf classifier/.swiftpm

build-classifier:
	$(eval SCHEME=classifier)
	$(XCODEBUILD) -project $(PROJECTDIR) \
		$(if $(VERBOSE), -verbose,) \
		-scheme $(SCHEME) \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk macosx \
		ARCHS=arm64 \
		$(if $(SHOW), -showdestinations,) \
		$(if $(CLEAN),clean,) build
		build_request=$$(find Build/Intermediates.noindex/XCBuildData -type f -name build-request.json)
		cat $$build_request

show-classifier-build-settings:
	$(eval SCHEME=classifier)
	$(XCODEBUILD) -project $(PROJECTDIR) \
		-scheme $(SCHEME) \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)" \
		-showBuildSettings

build-macosx:
	$(XCODEBUILD) -project $(PROJECTDIR) \
		-scheme geoCoordClassifier \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)"

get-macosx-bundle-identifier:
	defaults read $(CURDIR)/DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)/geoCoordClassifier.app/Contents/Info.plist CFBundleIdentifier

run-macosx:
	find DerivedData/geoCoordClassifier/Build/Products -type f -name "libonnxruntime*.dylib"
	open DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)/geoCoordClassifier.app \
	$(if $(VERBOSE),--args -verbose,)

build-cli-macosx:
	$(XCODEBUILD) $(if $(VERBOSE),-verbose,) \
		-project $(PROJECTDIR) \
		-scheme geoCoordClassifierCLI \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)"

run-cli-macosx:
	find DerivedData/geoCoordClassifier/Build/Products -type f -name "libonnxruntime*.dylib"
	cd DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)/
	./geoCoordClassifierCLI $(if $(VERBOSE),--verbose,)

build-ios-iphonesimulator:
	$(XCODEBUILD) -project $(PROJECTDIR) \
		-scheme geoCoordClassifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphonesimulator \
		-allowProvisioningUpdates \
		"ARCHS=$(ARCHS)"

#		"IPHONEOS_DEPLOYMENT_TARGET=25.0"

get-ios-iphonesimulator:
#	xcrun simctl list | awk -F'[()]' '/^\s+iPhone SE \(3rd generation\)/{print $$4}'
	xcrun simctl list | awk -F'[()]' '/^\s+iPhone Air\s+\(/{print $$2}'

start-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	open -a Simulator --args -CurrentDeviceUDID $(UDID)

stop-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	xcrun simctl shutdown $(UDID)

run-app-in-ios-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	$(eval BID=$(shell $(MAKE) get-bundle-identifier))
	xcrun simctl install $(UDID) $(CURDIR)/DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)-iphonesimulator/geoCoordClassifier.app
	xcrun simctl launch --arch=$(ARCHS) $(UDID) $(BID)

list-booted-simulators:
	xcrun simctl list devices | grep "Booted"

get-bundle-identifier:
	defaults read $(CURDIR)/DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)-iphonesimulator/geoCoordClassifier.app/Info CFBundleIdentifier

build-iphoneos:
	$(XCODEBUILD) -project $(PROJECTDIR) \
		-scheme geoCoordClassifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphoneos \
		-allowProvisioningUpdates \
    	-destination generic/platform=iOS \
		"ARCHS=$(ARCHS)"

sandbox-test:
	$(eval BRANCH=main)
	rm -rf /tmp/geo-coord-classifier
	cd /tmp
	git clone -b $(BRANCH) --single-branch \
		https://github.com/mi-parkes/geo-coord-classifier.git
	cd geo-coord-classifier
	cp -r $(CURDIR)/onnxruntime.xcframework .
	$(MAKE) build-classifier
	$(MAKE) build-macosx
	$(MAKE) build-cli-macosx
	$(MAKE) build-ios-iphonesimulator
	$(MAKE) build-iphoneos
	$(MAKE) test-geoCoordClassifierCore
	$(MAKE) run-cli-macosx
	$(if $(RUNUI),$(MAKE) run-macosx,)

test-geoCoordClassifierCore:
	$(eval SCHEME=geoCoordClassifierCore)
	$(eval TestBundlePath=/tmp/TestResults)
	rm -rf $(TestBundlePath)*
	$(XCODEBUILD) \
		$(if $(VERBOSE), -verbose,) \
		-project $(PROJECTDIR) \
		-scheme $(SCHEME) \
		-destination 'platform=macOS,arch=arm64' \
		-resultBundlePath $(TestBundlePath) \
		$(if $(SHOW), -showdestinations,) \
		$(if $(CLEAN),clean,) test
	$(if $(SHOW),open $(TestBundlePath).xcresult,)

-include $(UTILS)
