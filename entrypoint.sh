#!/bin/sh
# busybox

# The document version and the actual/publishing date.
export PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}

# CHROMIUM_PATH will export by Dockerfile
PUPPETEER_CHROMIUM_REVISION="$(${CHROMIUM_PATH} --version | awk '{print $2}' | sed -E 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\1\3/')"
exec "${@}"
