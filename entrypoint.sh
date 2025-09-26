#!/bin/sh
# busybox - ash

trap 'echo "${0} finished"; exit' QUIT TERM EXIT

# Container information is only output if no command line parameters are passed.
[ ${#} -eq 0 ] && /container_info.sh

# The document version and the actual/publishing date.
PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export PROJECT_VERSION
REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}
export REVISION_DATE

# CHROMIUM_PATH will export by Dockerfile
PUPPETEER_CHROMIUM_REVISION="$(${CHROMIUM_PATH} --version | awk '{print $2}' | sed -E 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\1\3/')"
export PUPPETEER_CHROMIUM_REVISION

[ "${ASCIIDOCTOR_DEBUG}" = "true" ] && echo "ASCIIDOCTOR_DEBUG: ${ASCIIDOCTOR_DEBUG}"
# Print Asciidoctor verbose output on stdout
[ "${ASCIIDOCTOR_DEBUG}" = "true" ] && /version.sh

[ "${PUPPETEER_DEBUG}" = "true" ] && echo "PUPPETEER_DEBUG: ${PUPPETEER_DEBUG}"
# PUPPETEER_CONFIG_FILE will export by Dockerfile
# beware of sed -i inline editing tries to create a temp. file beside original file (for now in '/')
# shellcheck disable=SC2005
echo "$(sed "s|\"dumpio\": *[^,]*|\"dumpio\": ${PUPPETEER_DEBUG:-false}|" "${PUPPETEER_CONFIG_FILE:-/puppeteer-config.json}")" > "${PUPPETEER_CONFIG_FILE:-/puppeteer-config.json}"

exec "${@}"
