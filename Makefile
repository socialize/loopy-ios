default: clean pods test integration-tests coverage

clean:
	xcodebuild -workspace Loopy.xcworkspace -scheme "TestApp" -configuration Release -sdk iphoneos clean
	xcodebuild -workspace Loopy.xcworkspace -scheme "UnitTests" -configuration Debug -sdk iphonesimulator clean
	xcodebuild -workspace Loopy.xcworkspace -scheme "IntegrationTests" -configuration Debug -sdk iphonesimulator clean
	rm -rfd build
	rm -rfd Pods

pods:
	pod install
	pod update

test:
	WRITE_JUNIT_XML=YES GHUNIT_CLI=1 xcodebuild -workspace Loopy.xcworkspace -scheme "UnitTests" -configuration Debug -sdk iphonesimulator build

integration-tests:
	WRITE_JUNIT_XML=YES GHUNIT_CLI=1 xcodebuild -workspace Loopy.xcworkspace -scheme "IntegrationTests" -configuration Debug -sdk iphonesimulator build

coverage:
	./XcodeCoverage/getcovcombined

sphinx_doc:
	export LANG=en_US.UTF-8;\
	export LC_ALL=en_US.UTF-8;\
	export LC_CTYPE=en_US.UTF-8;\
	ant -buildfile ./sphinx_doc.xml

framework:
	xcodebuild -scheme "Loopy Framework" -configuration Release

package: framework
	./Scripts/package.sh
