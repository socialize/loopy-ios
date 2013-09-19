test:
	SZEventTrackingDisabled=1 WRITE_JUNIT_XML=YES RUN_CLI=1 xcodebuild -scheme UnitTests -configuration Debug -sdk iphonesimulator

default: test

clean:
	xcodebuild -scheme "Loopy" -configuration Release -sdk iphoneos clean
	xcodebuild -scheme "UnitTests" -configuration Debug -sdk iphonesimulator clean
	xcodebuild -scheme "IntegrationTests" -configuration Debug -sdk iphonesimulator clean
	rm -rfd build

integration-tests:
	WRITE_JUNIT_XML=YES RUN_CLI=1 xcodebuild -scheme IntegrationTests -configuration Debug -sdk iphonesimulator build
