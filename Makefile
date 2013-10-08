default: clean test integration-tests coverage

clean:
	xcodebuild -workspace Loopy.xcworkspace -scheme "TestApp" -configuration Release -sdk iphoneos clean
	xcodebuild -workspace Loopy.xcworkspace -scheme "UnitTests" -configuration Debug -sdk iphonesimulator clean
	xcodebuild -workspace Loopy.xcworkspace -scheme "IntegrationTests" -configuration Debug -sdk iphonesimulator clean
	rm -rfd build

test:
	WRITE_JUNIT_XML=YES GHUNIT_CLI=1 xcodebuild -workspace Loopy.xcworkspace -scheme "UnitTests" -configuration Debug -sdk iphonesimulator build

integration-tests:
	WRITE_JUNIT_XML=YES GHUNIT_CLI=1 xcodebuild -workspace Loopy.xcworkspace -scheme "IntegrationTests" -configuration Debug -sdk iphonesimulator build

coverage:
	./XcodeCoverage/getcovcombined