.PHONY: build
build:
	swift package generate-xcodeproj
	xcodebuild -sdk iphonesimulator

.PHONY: test
test:
	swift package generate-xcodeproj
	xcodebuild test -scheme RouterService-Package -destination 'platform=iOS Simulator,name=iPhone 12,OS=14.4'

.PHONY: check_example
check_example:
	cd ./ExampleProject && xcodegen generate && xcodebuild -scheme RouterServiceExampleApp -sdk iphonesimulator -project RouterServiceExampleApp.xcodeproj