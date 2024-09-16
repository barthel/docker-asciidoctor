#!/bin/sh
# busybox - ash

trap 'echo "${0} finished"; exit' QUIT TERM EXIT

echo ""
# CONTAINER_INFORMATION will export by Dockerfile
echo "${CONTAINER_INFORMATION}"
echo ""

# The document version and the actual/publishing date.
PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export PROJECT_VERSION
REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}
export REVISION_DATE

# CHROMIUM_PATH will export by Dockerfile
PUPPETEER_CHROMIUM_REVISION="$(${CHROMIUM_PATH} --version | awk '{print $2}' | sed -E 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\1\3/')"
export PUPPETEER_CHROMIUM_REVISION

# Print Asciidoctor verbose output on stdout
for i in $(find /usr/bin -type f -executable -name "asciidoctor*" -print0 | cut -d- -f1-2 | sort -u )
do
  # @see: https://stackoverflow.com/a/18558871/4956096
  if case ${i} in *-confluence) true;; *) false;; esac
  then
    echo "asciidoctor-confluence ${ASCIIDOCTOR_CONFLUENCE_VERSION} -- seems to be discontinued. Use at your own risk."
#    touch ${TMPDIR}/temp.adoc
#    ${i}  --host 127.0.0.1 -spaceKey TMP --title TEMP --version ${TMPDIR}/temp.adoc 1> /dev/null
  else
    ${i} --version
  fi
  echo ""
done

[ -n "${PUPPETEER_DEBUG}" ] && echo "PUPPETEER_DEBUG: ${PUPPETEER_DEBUG}"
# PUPPETEER_CONFIG_FILE will export by Dockerfile
# beware of sed -i inline editing tries to create a temp. file beside original file (for now in '/')
# shellcheck disable=SC2005
echo "$(sed "s|\"dumpio\": *[^,]*|\"dumpio\": ${PUPPETEER_DEBUG:-true}|" "${PUPPETEER_CONFIG_FILE:-/puppeteer-config.json}")" > "${PUPPETEER_CONFIG_FILE:-/puppeteer-config.json}"

exec "${@}"
