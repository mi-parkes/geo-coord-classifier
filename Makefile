.ONESHELL:
SHELL           =/bin/bash
MAKEFLAGS       += $(if $(VERBOSE),,--no-print-directory)
MINMAKEVERSION  =3.82
$(if $(findstring $(MINMAKEVERSION),$(firstword $(sort $(MINMAKEVERSION) $(MAKE_VERSION)))),,$(error The Makefile requires minimal GNU make version:$(MINMAKEVERSION) and you are using:$(MAKE_VERSION)))

BUILD_CONFIGURATION = Debug
ARCHS = arm64

.PHONY: clean clean-res

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

clean: clean-res
	rm -rf DerivedData
	rm -rf geo-coord-classifier.xcodeproj/xcuserdata
	rm -rf geo-coord-classifier.xcodeproj/project.xcworkspace/xcuserdata
	rm -rf classifier/.swiftpm

clean-res:
	rm -rfv GeneratedSources Resources

build-macosx:
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)"

run-macosx:
	find DerivedData/geo-coord-classifier/Build/Products -type f -name "libonnxruntime*.dylib"
	open DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)/geo-coord-classifier.app

build-cli-macosx:
	xcodebuild $(if $(VERBOSE),-verbose,) -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier-cli \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=$(ARCHS)"

run-cli-macosx:
	export DYLD_LIBRARY_PATH=$$DYLD_LIBRARY_PATH:.
	find DerivedData/geo-coord-classifier/Build/Products -type f -name "libonnxruntime*.dylib"
	cd DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)/
	./geo-coord-classifier-cli $(if $(VERBOSE),--verbose,)

build-ios-iphonesimulator:
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphonesimulator \
		"ARCHS=$(ARCHS)"

get-ios-iphonesimulator:
	xcrun simctl list | awk -F'[()]' '/^\s+iPhone SE \(3rd generation\)/{print $$4}'

start-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	open -a Simulator --args -CurrentDeviceUDID $(UDID)

stop-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	xcrun simctl shutdown $(UDID)

run-app-in-ios-simulator:
	$(eval UDID=$(shell $(MAKE) get-ios-iphonesimulator))
	$(eval BID=$(shell $(MAKE) get-bundle-identifier))
	xcrun simctl install $(UDID) $(CURDIR)/DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)-iphonesimulator/geo-coord-classifier.app
	xcrun simctl launch --arch=$(ARCHS) $(UDID) $(BID)

list-booted-simulators:
	xcrun simctl list devices | grep "Booted"

get-bundle-identifier:
	defaults read $(CURDIR)/DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)-iphonesimulator/geo-coord-classifier.app/Info CFBundleIdentifier

build-iphoneos:
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphoneos \
    	-destination generic/platform=iOS \
		"ARCHS=$(ARCHS)"
