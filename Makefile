.ONESHELL:
SHELL           =/bin/bash
MAKEFLAGS       += $(if $(VERBOSE),,--no-print-directory)
MINMAKEVERSION  =3.82
$(if $(findstring $(MINMAKEVERSION),$(firstword $(sort $(MINMAKEVERSION) $(MAKE_VERSION)))),,$(error The Makefile requires minimal GNU make version:$(MINMAKEVERSION) and you are using:$(MAKE_VERSION)))

BUILD_CONFIGURATION = Debug

.PHONY: clean

$(MAKE_VERBOSE).SILENT:
	echo NothingAtAll

clean:
	rm -rf DerivedData
	rm -rf geo-coord-classifier.xcodeproj/xcuserdata
	rm -rf geo-coord-classifier.xcodeproj/project.xcworkspace/xcuserdata
	rm -rf classifier/.swiftpm

build-macosx: clean
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=arm64"

run-macosx:
	find DerivedData/geo-coord-classifier/Build/Products -type f -name "libonnxruntime*.dylib"
	open DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)/geo-coord-classifier.app

build-cli-macosx: clean
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier-cli \
		-configuration $(BUILD_CONFIGURATION) \
		"ARCHS=arm64"

run-cli-macosx:
	export DYLD_LIBRARY_PATH=$$DYLD_LIBRARY_PATH:.
	find DerivedData/geo-coord-classifier/Build/Products -type f -name "libonnxruntime*.dylib"
	cd DerivedData/geo-coord-classifier/Build/Products/$(BUILD_CONFIGURATION)/
	./geo-coord-classifier-cli

build-ios-iphonesimulator: clean
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphonesimulator \
		"ARCHS=arm64"

build-iphoneos: clean
	xcodebuild -project geo-coord-classifier.xcodeproj \
	    -scheme geo-coord-classifier \
		-configuration $(BUILD_CONFIGURATION) \
		-sdk iphoneos \
    	-destination generic/platform=iOS \
		"ARCHS=arm64"
