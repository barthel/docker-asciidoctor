# Asciidoctor &mdash; multi platform Edition

The goal of this project is to build a multi-platform (arm64, amd64) Docker image based on the original [Asciidoctor Docker image](https://github.com/asciidoctor/docker-asciidoctor) and adding all extra diagram tools supported by [Asciidoctor Diagram](https://docs.asciidoctor.org/diagram-extension/latest/).

An overview of all supported diagram types, generated as HTML and as PDF, can be found here: https://barthel.github.io/docker-asciidoctor/

## ⚠️ Note

The original [Asciidoctor Docker image](https://github.com/asciidoctor/docker-asciidoctor) is delivered from version [*1.63.0*](https://github.com/asciidoctor/docker-asciidoctor/releases/tag/1.63.0) as a multi platform container with `amd64` and `arm64`.

Unfortunately, it is not possible to provide **`armv7`** version greater than [1.46](https://github.com/barthel/docker-asciidoctor/releases/tag/1.46.0) anymore because updated Java-based tools no longer use Java 8 and there is no Java runtime environment greater than version 8 on Alpine Linux **`armv7`**.

## Additional diagram tools

The following additional diagram tools are installed:

* [ASCIIToSVG](https://github.com/asciitosvg/asciitosvg)<sup>[1]</sup>
* [barby](https://github.com/toretore/barby)<sup>[1]</sup>
* [blockdiag/blockdiag](https://github.com/blockdiag/blockdiag)<sup>[1]</sup>
* [blockdiag/actdiag](https://github.com/blockdiag/actdiag)<sup>[1]</sup>
* [blockdiag/nwdiag](https://github.com/blockdiag/nwdiag)<sup>[1]</sup>
* [blockdiag/seqdiag](https://github.com/blockdiag/seqdiag)<sup>[1]</sup>
* [bpmn-js-cmd](https://github.com/gtudan/bpmn-js-cmd)
* [bytefield-svg](https://github.com/Deep-Symmetry/bytefield-svg)
* [diagrams](https://diagrams.mingrammer.com/)
* [ditaa](https://ditaa.sourceforge.net/)<sup>[1]</sup>
* [dpic](https://gitlab.com/aplevich/dpic)
* [erd-go](https://github.com/kaishuu0123/erd-go/)
* [gnuplot](http://gnuplot.info/)<sup>[1]</sup>
* [graphviz](https://graphviz.gitlab.io/)<sup>[1]</sup>
* [imagemagick](https://asciidoctor.org/docs/asciidoctor-diagram/#meme) for meme
* [mermaid](https://github.com/mermaid-js/mermaid-cli)
<!-- * [mscgen_js](https://github.com/mscgenjs/mscgenjs-cli) -->
* [nomnoml](https://github.com/skanaar/nomnoml)
* [pikchr](https://pikchr.org)
* [plantuml](https://plantuml.com/)<sup>[1]</sup>
* [state-machine-cat (smcat)](https://github.com/sverweij/state-machine-cat/)
* [svgbob](https://github.com/ivanceras/svgbob)
* [symbolator](https://github.com/hdl/symbolator) uses fork, because of incompatible python setup (2to3)
* [syntrax](https://kevinpt.github.io/syntrax)
* [tikz](https://github.com/pgf-tikz/pgf)
* [umlet](https://www.umlet.com)
* [vega](https://vega.github.io/vega) and [vega-lite](https://vega.github.io/vega-lite)
* [wavedrom](https://wavedrom.com/)

Additional non-diagram tools:
* [htmlark](https://github.com/BitLooter/htmlark)  
  > Embed images, CSS, and JavaScript into an HTML file. Through the magic of data URIs, HTMLArk can save these external dependencies inline right in the HTML. \
  > &mdash;David Powell, https://github.com/BitLooter/htmlark
* [inliner](https://github.com/barthel/inliner) fork of https://github.com/remy/inliner
  > Turns your web page to a single HTML file with everything inlined - perfect for appcache manifests on mobile devices that you want to reduce those http requests.
  > &mdash;Remy Sharp, https://github.com/remy/inliner
* [asciidoctor-extensions](https://github.com/asciidoctor/asciidoctor-extensions-lab) available in `/usr/local/asciidoctor-extensions` and could be used like: `asciidoctor -r /usr/local/asciidoctor-extensions/lib/glob-include-processor.rb ...` \
  ⚠ Please do not use this code in production. The code is untested.
* [asciidoctor-multipage](https://github.com/owenh000/asciidoctor-multipage)
  > It extends the stock HTML converter to generate multiple HTML pages from a single, large source document.
* [asciidoctor-lists](https://github.com/Alwinator/asciidoctor-lists)
  > An asciidoctor extension that adds a list of figures, a list of tables, or a list of anything you want.

## ⚠️ Note

The following diagram tools are not installed because there is no executable file for all supported platforms:

* [erd](https://github.com/BurntSushi/erd) was replaced by [erd-go](https://github.com/kaishuu0123/erd-go/)
* [mscgen](http://www.mcternan.me.uk/mscgen/) (has been replaced by [mscgen_js](https://github.com/mscgenjs/mscgenjs-cli), but is currently not maintained)
* [shaape](https://github.com/christiangoltz/shaape)

## Usage

Generate HTML document:
```bash
docker run --rm \
  -v $(pwd)/src/doc:/documents/ \
  -v $(pwd)/dist:/dist \
  docker.io/uwebarthel/asciidoctor:latest \
    asciidoctor \
      -b html5 \
      -D "/dist" \
      -r asciidoctor-diagram \
      -r asciidoctor-mathematical \
      -r /usr/local/asciidoctor-extensions/lib/glob-include-processor.rb \
      /documents/asciidoctor-diagram_overview.adoc
```

Generate inlined HTML document via `inliner` based on generated HTML document:
```bash
docker run --rm -it \
  -v $(pwd)/dist:/dist \
  docker.io/uwebarthel/asciidoctor:latest \
    inliner \
      --nocompress \
      --preserve-comments \
      --inlinemin \
      --videos \
      /dist/asciidoctor-diagrams_overview.html 2>/dev/null 1> dist/asciidoctor-diagrams_overview_inlined.html
```

Generate PDF document:
```bash
docker run --rm \
  -v $(pwd)/src/doc:/documents/ \
  -v $(pwd)/dist:/dist \
  docker.io/uwebarthel/asciidoctor:latest \
    asciidoctor-pdf \
      -D "/dist" \
      -r asciidoctor-diagram \
      -r asciidoctor-mathematical \
      -r /usr/local/asciidoctor-extensions/lib/glob-include-processor.rb \
      /documents/asciidoctor-diagram_overview.adoc
```

Docker Hub: https://hub.docker.com/r/uwebarthel/asciidoctor

## Building

```bash
docker build \
  --build-arg CONTAINER_INFORMATION="docker.io/uwebarthel/asciidoctor:latest ($(git rev-parse --short HEAD))" \
  --tag uwebarthel/asciidoctor:latest \
  --tag docker.io/uwebarthel/asciidoctor:latest \
  .
```
---
<sup>[1]</sup> provided by original Asciidoctor Docker Image
