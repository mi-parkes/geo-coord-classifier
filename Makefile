.ONESHELL:
SHELL           =/bin/bash
.SHELLFLAGS 	= -e -c
MAKEFLAGS       += $(if $(VERBOSE),,--no-print-directory)
MINMAKEVERSION  =3.82
$(if $(findstring $(MINMAKEVERSION),$(firstword $(sort $(MINMAKEVERSION) $(MAKE_VERSION)))),,$(error The Makefile requires minimal GNU make version:$(MINMAKEVERSION) and you are using:$(MAKE_VERSION)))

BUILD_CONFIGURATION = Debug
ARCHS = arm64
PROJECTDIR = geoCoordClassifier.xcodeproj

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
	echo $(MAKE) build-ios-iphonesimulator
	echo $(MAKE) start-simulator
	echo $(MAKE) run-app-in-ios-simulator
	echo $(MAKE) build-iphoneos

targets:
	xcodebuild -list -project $(PROJECTDIR)

sdks:
	xcodebuild -showsdks

destinations:
	xcodebuild  -project $(PROJECTDIR) -scheme geoCoordClassifier -showdestinations
	xcodebuild  -project $(PROJECTDIR) -scheme geoCoordClassifierCLI -showdestinations

clean:
	rm -rf DerivedData
	rm -rf Build
	rm -rf $(PROJECTDIR)/xcuserdata
	rm -rf $(PROJECTDIR)/project.xcworkspace/xcuserdata
	rm -rf classifier/.swiftpm

build-macosx:
	xcodebuild -project $(PROJECTDIR) \
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
	xcodebuild $(if $(VERBOSE),-verbose,) \
		-project $(PROJECTDIR) \
		-scheme geoCoordClassifierCLI \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)"

run-cli-macosx:
#	export DYLD_LIBRARY_PATH=$$DYLD_LIBRARY_PATH:.
	find DerivedData/geoCoordClassifier/Build/Products -type f -name "libonnxruntime*.dylib"
	cd DerivedData/geoCoordClassifier/Build/Products/$(BUILD_CONFIGURATION)/
	./geoCoordClassifierCLI $(if $(VERBOSE),--verbose,)

build-ios-iphonesimulator:
	xcodebuild -project $(PROJECTDIR) \
		-scheme geoCoordClassifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphonesimulator \
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
	xcodebuild -project $(PROJECTDIR) \
		-scheme geoCoordClassifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphoneos \
    	-destination generic/platform=iOS \
		"ARCHS=$(ARCHS)"

sandbox-test:
	rm -rf /tmp/geo-coord-classifier
	cd /tmp
	git clone https://github.com/mi-parkes/geo-coord-classifier.git
	cd geo-coord-classifier
	cp -r $(CURDIR)/onnxruntime.xcframework .
	$(MAKE) build-macosx
	$(MAKE) build-ios-iphonesimulator
	$(MAKE) build-iphoneos

-include ../utils.mak
