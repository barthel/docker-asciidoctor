#!/bin/sh
# busybox

# The document version and the actual/publishing date.
PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export PROJECT_VERSION
REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}
export REVISION_DATE

sed -i "s|\"dumpio\": *[^,]*|\"dumpio\": ${PUPPETEER_DEBUG:-true}|" /usr/local/puppeteer-config.json

# CHROMIUM_PATH will export by Dockerfile
PUPPETEER_CHROMIUM_REVISION="$(${CHROMIUM_PATH} --version | awk '{print $2}' | sed -E 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\1\3/')"
export PUPPETEER_CHROMIUM_REVISION
exec "${@}"
