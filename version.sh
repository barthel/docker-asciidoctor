#!/bin/sh
# busybox - ash

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
