#!/bin/sh

# If we aren't running from the command line, then exit
if [ "$GHUNIT_CLI" = "" ] && [ "$GHUNIT_AUTORUN" = "" ]; then
  exit 0
fi

# DOES NOT WORK with 7.1 simulator; force version to 7.0
export SDKROOT="$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.0.sdk/"
export DYLD_ROOT_PATH="$SDKROOT"
export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
export IPHONE_SIMULATOR_ROOT="$SDKROOT"
echo "SDKROOT =" $SDKROOT

export NSDebugEnabled=YES
export NSZombieEnabled=YES
export NSDeallocateZombies=NO
export NSHangOnUncaughtException=YES
export NSAutoreleaseFreedObjectCheckEnabled=YES
export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"

TEST_TARGET_EXECUTABLE_PATH="$TARGET_BUILD_DIR/$EXECUTABLE_PATH"

if [ ! -e "$TEST_TARGET_EXECUTABLE_PATH" ]; then
  echo ""
  echo "  ------------------------------------------------------------------------"
  echo "  Missing executable path: "
  echo "     $TEST_TARGET_EXECUTABLE_PATH."
  echo "  The product may have failed to build or could have an old xcodebuild in your path (from 3.x instead of 4.x)."
  echo "  ------------------------------------------------------------------------"
  echo ""
  exit 1
fi

SCRIPTS_PATH=`cd $(dirname $0); pwd`

killall "iPhone Simulator" >/dev/null 2>&1
RUN_CMD="\"$TEST_TARGET_EXECUTABLE_PATH\" -RegisterForSystemEvents"

echo "Running: $RUN_CMD"
set +o errexit # Disable exiting on error so script continues if tests fail
eval $RUN_CMD
RETVAL=$?
set -o errexit

unset DYLD_ROOT_PATH
unset DYLD_FRAMEWORK_PATH
unset IPHONE_SIMULATOR_ROOT

if [ -n "$WRITE_JUNIT_XML" ]; then
  MY_TMPDIR=`/usr/bin/getconf DARWIN_USER_TEMP_DIR`
  RESULTS_DIR="${MY_TMPDIR}test-results"

  if [ -d "$RESULTS_DIR" ]; then
    `$CP -r "$RESULTS_DIR" "$BUILD_DIR" && rm -r "$RESULTS_DIR"`
  fi
fi

exit $RETVAL