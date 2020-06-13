.PHONY: build
build:
	swift package generate-xcodeproj
	xcodebuild -sdk iphonesimulator

.PHONY: test
test:
	swift package generate-xcodeproj
	xcodebuild test -scheme RouterService-Package -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.4.1'