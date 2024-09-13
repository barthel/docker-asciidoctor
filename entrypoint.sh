#!/bin/sh
# busybox

# The document version and the actual/publishing date.
export PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}

export CHROMIUM_PATH="$(which chromium-browser)"
export PUPPETEER_EXECUTABLE_PATH="${CHROMIUM_PATH}"

exec "${@}"
