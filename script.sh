#!/bin/sh

version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "${GITHUB_WORKSPACE}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing diff-cover ... https://github.com/Bachmann1234/diff_cover'
pip install diff-cover==$INPUT_DIFF_COVER_VERSION
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running diff-cover ...'
diff-cover --json-report ${TEMP_PATH}/report.json \
  ${INPUT_DIFF_COVER_FLAGS} \
  ${INPUT_COVERAGE_FILES}
echo '::endgroup::'

echo '::group:: Running diff-cover with reviewdog 🐶 ...'
$GITHUB_ACTION_PATH/process.py ${TEMP_PATH}/report.json \
  | reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}

reviewdog_rc=$?

echo '::endgroup::'

exit $reviewdog_rc
