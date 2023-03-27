ARG ASCIIDOCTOR_BASE_TAG=${CIRCLE_TAG:-latest}
ARG alpine_version=3.17.2
ARG golang_version=1.14
# Build ASCIIToSVG - @see: https://github.com/asciitosvg/asciitosvg
FROM golang:${golang_version}-alpine as go-builder

RUN apk add --no-cache git \
    && go get github.com/asciitosvg/asciitosvg/cmd/a2s


# =========================================
# Build dpic- @see: https://gitlab.com/aplevich/dpic
# Build pikchr - @see: https://github.com/drhsqlite/pikchr
FROM alpine:${alpine_version} as make-builder

RUN apk add --no-cache \
        build-base \
        make \
        bison \
        git \
    && git clone --depth 1 https://gitlab.com/aplevich/dpic.git /dpic \
    && cd /dpic \
    && make PREFIX=local installdpic \
    && git clone --depth 1 -b "master" https://github.com/drhsqlite/pikchr.git /pikchr \
    && cd /pikchr \
    && make pikchr

# =========================================

FROM uwebarthel/asciidoctor-base:${ASCIIDOCTOR_BASE_TAG}

ENV TMPDIR "/tmp"

# Install ASCIIToSVG
COPY --from=go-builder /go/bin/a2s /usr/local/bin/
# Install dpic
COPY --from=make-builder /usr/local/bin/dpic /usr/local/bin/
# Install pikchr
COPY --from=make-builder /pikchr/pikchr /usr/local/bin/

# @see: https://gitlab.alpinelinux.org/alpine/infra/infra/-/issues/8087
# @see: https://github.com/alpinelinux/docker-alpine/issues/98
RUN sed -i 's/https/http/' /etc/apk/repositories
# Adds edge/testing package repo for svgbob, pdf2svg
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk fix && apk update

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 'Native' apk packages
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install gnuplot - @see: http://gnuplot.info/
# Install imagemagick for meme - @see: https://asciidoctor.org/docs/asciidoctor-diagram/#meme
# Install svgbob - @see: https://github.com/ivanceras/svgbob
# Install tikz (texlive, pdf2svg) - @see:https://github.com/pgf-tikz/pgf
RUN apk --no-cache add \
        gnuplot \
        imagemagick \
        svgbob@testing \
        texlive \
        pdf2svg@testing \
        git

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 'Node.js' packages
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install mermaid-cli - @see: https://github.com/mermaid-js/mermaid-cli
ARG mermaid_version="10.0.2"
# Install mscgenjs-cli - @see: https://github.com/mscgenjs/mscgenjs-cli
ARG mscgen_version="6.0.0"
# Install bpmn-js-cmd - @see: https://github.com/gtudan/bpmn-js-cmd
ARG bpmn_version="0.4.0"
# Install bytefield-svg - @see: https://github.com/Deep-Symmetry/bytefield-svg
ARG bytefield_version="1.8.0"
# Install nomnoml - @see: https://github.com/skanaar/nomnoml
ARG nomnoml_version="1.5.3"
# Install state-machine-cat (smcat) - @see: https://github.com/sverweij/state-machine-cat/
ARG smc_version="10.1.10"
# @see: https://github.com/puppeteer/puppeteer/issues/379#issuecomment-437688436
# @see: https://github.com/puppeteer/puppeteer/blob/v2.1.1/docs/api.md#environment-variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD "true"
ENV puppeteer_skip_download "true"
# Puppeteer version and Chromium version are related
ARG puppeteer_version="19.7.5"
ENV PUPPETEER_CHROMIUM_REVISION "1105481"
ENV puppeteer_chromium_revision "1105481"
# ENV CHROMIUM_PATH "$(which chromium-browser)" # will be exported by entrypoint.sh
# @see: https://github.com/nodejs/docker-node/issues/1794
# @see: https://github.com/nodejs/docker-node/issues/1798
# @see: https://superuser.com/a/1058665
# @see: https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
# !!! 
# Split into several `yarn add` and `yarn install` steps because of
# 'There appears to be trouble with your network connection. Retrying…' issue in Circle CI
# !!!
RUN apk --no-cache add \
        nodejs \
        'chromium~=110.0.5481' \
        nss \
        freetype \
        harfbuzz \
        ttf-freefont \
    && apk --no-cache --virtual .nodejsyarndepends add yarn \
    && echo "Install puppeteer@${puppeteer_version}" \
    && yarn global add --network-timeout 3600000 \
        "puppeteer-core@${puppeteer_version}" \
        "puppeteer@${puppeteer_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo "Install mermaid-cli@${mermaid_version}" \
    && yarn global add --network-timeout 3600000 \
        "@mermaid-js/mermaid-cli@${mermaid_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo -e "{\n\t\"product\": \"chrome\",\n\t\"headless\": true,\n\t\"executablePath\": \"$(which chromium-browser)\",\n\t\"ignoreHTTPSErrors\": true,\n\t\"args\": [\n\t\t\"--no-sandbox\",\n\t\t\"--allow-insecure-localhost\",\n\t\t\"--timeout 30000\"\n\t]\n}" > /usr/local/mmdc_puppeteer-config.json \
    && echo "Install mscgen-cli@${mscgen_version}" \
    && yarn global add --network-timeout 3600000 \
        "mscgenjs-cli@${mscgen_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo -e "{\n\t\"devtools\": false,\n\t\"headless\": true,\n\t\"executablePath\": \"$(which chromium-browser)\",\n\t\"timeout\": 30000,\n\t\"args\": [\n\t\t\"--no-sandbox\",\n\t\t\"--allow-insecure-localhost\"\n\t]\n}" > /usr/local/mscgen_js_puppeteer-config.json \
    && echo "Install bpmn-js-cmd@${bpmn_version}" \
    && yarn global add --network-timeout 3600000 \
        "bpmn-js-cmd@${bpmn_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo "Install bytefield-svg@${bytefield_version}" \
    && yarn global add --network-timeout 3600000 \
        "bytefield-svg@${bytefield_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo "Install nomnoml@${nomnoml_version}" \
    && yarn global add --network-timeout 3600000 \
        "nomnoml@${nomnoml_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo "Install state-machine-cat@${smc_version}" \
    && yarn global add --network-timeout 3600000 \
        "state-machine-cat@${smc_version}" \
    && find / -name yarn.lock -exec rm {} \; \
    && yarn install --no-lockfile --network-timeout 3600000 \
    && echo "Adapt executable" \
    && mv /usr/local/bin/mmdc /usr/local/bin/mmdc.node \
    && rm -f /usr/local/bin/mmdc \
    && echo -e "#!/bin/sh\n/usr/local/bin/mmdc.node --puppeteerConfigFile /usr/local/mmdc_puppeteer-config.json \${@}" > /usr/local/bin/mmdc \
    && chmod +x /usr/local/bin/mmdc \
    && mv /usr/local/bin/mscgen_js /usr/local/bin/mscgen_js.node \
    && rm -f /usr/local/bin/mscgen_js \
    && echo -e "#!/bin/sh\n/usr/local/bin/mscgen_js.node --puppeteer-options /usr/local/mscgen_js_puppeteer-config.json \${@}" > /usr/local/bin/mscgen_js \
    && ln -snf /usr/local/bin/mscgen_js /usr/local/bin/mscgen \
    && chmod +x /usr/local/bin/mscgen* \
    && apk del .nodejsyarndepends

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 'Ruby' packages
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install barby
RUN apk add --no-cache --virtual .rubymakedepends \
      build-base \
      libxml2-dev \
      ruby-dev \
    && gem install --no-document \
        barby rqrcode chunky_png \
    && apk del -r --no-cache .rubymakedepends

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 'Python' packages
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install diagrams - @see: https://diagrams.mingrammer.com/docs/getting-started/installation
# Install symbolator - @see: https://github.com/hdl/symbolator (fork because of incompatible setup 2to3)
RUN apk add --no-cache  \
        python3 \
        py3-pillow \
        py3-setuptools \
        py3-typed-ast \
        py3-gobject3 \
        py3-cairo \
        py3-cairosvg \
    && apk add --no-cache --virtual .pythonmakedepends \
        build-base \
        freetype-dev \
        python3-dev \
        py3-gobject3-dev \
        py3-cairo-dev \
        py3-pip \
    && pip3 install --no-cache-dir \
        https://github.com/hdl/pyhdlparser/tarball/master \
        https://github.com/hdl/symbolator/tarball/master \
        diagrams \
    && apk del -r --no-cache .pythonmakedepends
# Install syntrax - @see: https://github.com/kevinpt/syntrax.git (requires manually fix incompatible setup 2to3)
# The setup command 'use_2to3' is not supported anymore by setuptools - @see: https://github.com/pypa/setuptools/issues/2775
# The 'collections' import has changed with python 3.10 and must be adapted - @see: https://github.com/python/cpython/issues/89934
RUN apk add --no-cache \
        git \
        python3 \
        py3-pillow \
        py3-setuptools \
        py3-typed-ast \
        py3-gobject3 \
        py3-cairo \
        py3-cairosvg \
    && apk add --no-cache --virtual .pythonsyntraxdepends \
        build-base \
        freetype-dev \
        python3-dev \
        py3-gobject3-dev \
        py3-cairo-dev \
        py3-pip \
    && git clone https://github.com/kevinpt/syntrax.git ${TMPDIR}/syntrax \
    && sed -i 's|use_2to3 = True,||' ${TMPDIR}/syntrax/setup.py \
    && 2to3 --no-diffs -p -e -W -n -w ${TMPDIR}/syntrax \
    && sed -i 's|import collections|import collections.abc|' ${TMPDIR}/syntrax/syntrax.py \
    && sed -i 's|collections.Sequence|collections.abc.Sequence|g' ${TMPDIR}/syntrax/syntrax.py \
    && pip3 install --no-cache-dir \
        ${TMPDIR}/syntrax \
    && rm -rf ${TMPDIR}/synthrax \
    && apk del -r --no-cache .pythonsyntraxdepends

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Asciidoc extensions
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install asciidoctor extensions
# @see: https://docs.asciidoctor.org/asciidoctor/latest/extensions/
# @see: https://github.com/asciidoctor/asciidoctor-extensions-lab
# !!! Please do not use this code in production. !!!
RUN git clone --depth 1 https://github.com/asciidoctor/asciidoctor-extensions-lab.git /usr/local/asciidoctor-extensions
