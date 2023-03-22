ARG ASCIIDOCTOR_BASE_TAG=${CIRCLE_TAG:-latest}
# Build ASCIIToSVG - @see: https://github.com/asciitosvg/asciitosvg
FROM golang:1.14-alpine as a2s

RUN apk add git \
    && go get github.com/asciitosvg/asciitosvg/cmd/a2s

# =========================================

FROM uwebarthel/asciidoctor-base:${ASCIIDOCTOR_BASE_TAG}

# @see: https://gitlab.alpinelinux.org/alpine/infra/infra/-/issues/8087
# @see: https://github.com/alpinelinux/docker-alpine/issues/98
RUN sed -i 's/https/http/' /etc/apk/repositories
RUN apk fix && apk update

# Install imagemagick for meme - @see: https://asciidoctor.org/docs/asciidoctor-diagram/#meme
RUN apk --no-cache add imagemagick

# Install mermaid-cli - @see: https://github.com/mermaid-js/mermaid-cli
# Install mscgenjs-cli - @see: https://github.com/mscgenjs/mscgenjs-cli
# @see: https://github.com/puppeteer/puppeteer/issues/379#issuecomment-437688436
# @see: https://github.com/puppeteer/puppeteer/blob/v2.1.1/docs/api.md#environment-variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD "true"
ENV puppeteer_skip_download "true"
ENV PUPPETEER_CHROMIUM_REVISION "1105481"
# ENV CHROMIUM_PATH "$(which chromium-browser)" # will be exported by entrypoint.sh
# @see: https://github.com/nodejs/docker-node/issues/1794
# @see: https://github.com/nodejs/docker-node/issues/1798
# @see: https://superuser.com/a/1058665
# @see: https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
RUN apk --no-cache add \
        nodejs \
        'chromium~=110.0.5481' \
        nss \
        freetype \
        harfbuzz \
        ttf-freefont
RUN apk --no-cache --virtual yarn-dependencies add yarn \
    && yarn global add \
        --no-progress \
        puppeteer \
        @mermaid-js/mermaid-cli \
        mscgenjs-cli \
        bpmn-js-cmd \
    && yarn install
# mermaid-cli
RUN echo -e "{\n\t\"product\": \"chrome\",\n\t\"headless\": true,\n\t\"executablePath\": \"$(which chromium-browser)\",\n\t\"ignoreHTTPSErrors\": true,\n\t\"args\": [\n\t\t\"--no-sandbox\",\n\t\t\"--allow-insecure-localhost\",\n\t\t\"--timeout 30000\"\n\t]\n}" > /usr/local/mmdc_puppeteer-config.json \
    && mv /usr/local/bin/mmdc /usr/local/bin/mmdc.node \
    && rm -f /usr/local/bin/mmdc \
    && echo -e "#!/bin/sh\n/usr/local/bin/mmdc.node -p /usr/local/mmdc_puppeteer-config.json \${@}" > /usr/local/bin/mmdc \
    && chmod +x /usr/local/bin/mmdc
# mscgenjs-cli
RUN echo -e "{\n\t\"devtools\": false,\n\t\"headless\": true,\n\t\"executablePath\": \"$(which chromium-browser)\",\n\t\"timeout\": 30000,\n\t\"args\": [\n\t\t\"--no-sandbox\",\n\t\t\"--allow-insecure-localhost\"\n\t]\n}" > /usr/local/mscgen_js_puppeteer-config.json \
    && mv /usr/local/bin/mscgen_js /usr/local/bin/mscgen_js.node \
    && rm -f /usr/local/bin/mscgen_js \
    && echo -e "#!/bin/sh\n/usr/local/bin/mscgen_js.node --puppeteer-options /usr/local/mscgen_js_puppeteer-config.json \${@}" > /usr/local/bin/mscgen_js \
    && ln -snf /usr/local/bin/mscgen_js /usr/local/bin/mscgen \
    && chmod +x /usr/local/bin/mscgen*
RUN apk del yarn-dependencies

# Cleans up and Removes apk cache
RUN rm -rf /var/cache/apk/* \
    && rm -rf /usr/include \
    && rm -rf /root/.node-gyp /usr/share/man /tmp/*

# Install ASCIIToSVG
COPY --from=a2s /go/bin/a2s /usr/local/bin/

# Install barby
RUN apk add --no-cache --virtual .rubymakedepends \
      build-base \
      libxml2-dev \
      ruby-dev \
    && gem install --no-document \
        barby rqrcode chunky_png \
    && apk del -r --no-cache .rubymakedepends

# Install asciidoctor extensions
# @see: https://docs.asciidoctor.org/asciidoctor/latest/extensions/
# @see: https://github.com/asciidoctor/asciidoctor-extensions-lab
# !!! Please do not use this code in production. !!!
RUN git clone --depth 1 https://github.com/asciidoctor/asciidoctor-extensions-lab.git /usr/local/asciidoctor-extensions
