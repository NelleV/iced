#!/bin/bash
# This script is meant to be called by the "script" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.

# License: 3-clause BSD

set -e
set -v

python --version
python -c "import numpy; print('numpy %s' % numpy.__version__)"
python -c "import scipy; print('scipy %s' % scipy.__version__)"
python -c "import pandas; print('pandas %s' % pandas.__version__)"
python -c "import multiprocessing as mp; print('%d CPUs' % mp.cpu_count())"

run_tests() {
    TEST_CMD="pytest --showlocals --pyargs"

    # Get into a temp directory to run test from the installed scikit learn
    # and
    # check if we do not leave artifacts
    mkdir -p $TEST_DIR
    pushd $TEST_DIR

    if [[ "$COVERAGE" == "true" ]]; then
        TEST_CMD="$TEST_CMD --cov=iced --cov-report=xml"
    fi
    $TEST_CMD iced
    popd
    
}

run_ice_scripts() {
    pushd examples/HiC-pro
    bash launch_tests.sh
    popd
}

run_doc() {
    pushd doc
    mkdir -p _build/html
    make
    touch _build/html/.nojekyll
    popd
}

if [[ "$RUN_FLAKE8" == "true" ]]; then
    source build_tools/travis/flake8_diff.sh
fi

if [[ "$SKIP_TESTS" != "true" ]]; then
    run_tests
    run_ice_scripts
fi

if [[ "$DOC" == "true" ]]; then
    run_doc
fi
