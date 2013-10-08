#
#   Copyright 2012 Jonathan M. Reid. See LICENSE.txt
#   Created by: Jon Reid, http://qualitycoding.org/
#   Source: https://github.com/jonreid/XcodeCoverage
#

source env.sh

COVERAGE_OUTPUT_ROOT=build/test-coverage
COVERAGE_OUTPUT_DIR=${COVERAGE_OUTPUT_ROOT}/${EXECUTABLE_NAME}
COVERAGE_OUTPUT_PATH=${PROJECT_DIR}/${COVERAGE_OUTPUT_DIR}
LCOV_INFO=${EXECUTABLE_NAME}Coverage.info
LCOV_PATH=${SRCROOT}/XcodeCoverage/lcov-1.10/bin
LCOV=${LCOV_PATH}/lcov
OBJ_DIR=${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}
