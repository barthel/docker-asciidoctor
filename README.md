# Asciidoctor &mdash; multi platform Edition

The goal of this project is to build a multi-platform (especially armv7) Docker image based on the original [Asciidoctor Base/Original &mdash; multi-platform Edition](https://github.com/barthel/docker-asciidoctor-base) and adding the following extra diagram tools:

* [ASCIIToSVG](https://github.com/asciitosvg/asciitosvg)
* [barby](https://github.com/toretore/barby)
* [blockdiag/blockdiag](https://github.com/blockdiag/blockdiag)<sup>[1]</sup>
* [blockdiag/actdiag](https://github.com/blockdiag/actdiag)<sup>[1]</sup>
* [blockdiag/nwdiag](https://github.com/blockdiag/nwdiag)<sup>[1]</sup>
* [blockdiag/seqdiag](https://github.com/blockdiag/seqdiag)<sup>[1]</sup>
* [bpmn-js-cmd](https://github.com/gtudan/bpmn-js-cmd)
* [bytefield-svg](https://github.com/Deep-Symmetry/bytefield-svg)
* [diagrams](https://diagrams.mingrammer.com/)
* [ditaa](https://ditaa.sourceforge.net/)<sup>[1]</sup>
* [dpic](https://gitlab.com/aplevich/dpic)
* [imagemagick](https://asciidoctor.org/docs/asciidoctor-diagram/#meme) for meme
* [mermaid](https://github.com/mermaid-js/mermaid-cli)
* [erd-go](https://github.com/kaishuu0123/erd-go/)
* [mscgen_js](https://github.com/mscgenjs/mscgenjs-cli)


* [asciidoctor-extensions](https://github.com/asciidoctor/asciidoctor-extensions-lab) available in `/usr/local/asciidoctor-extensions` and could be used like: `asciidoctor -r /usr/local/asciidoctor-extensions/lib/glob-include-processor.rb ...` \
  ⚠ Please do not use this code in production. The code is untested.

## ⚠️ Note

The following diagram tools are not installed because there is no executable file for all supported platforms:

* [erd](https://github.com/BurntSushi/erd) was replaced by [erd-go](https://github.com/kaishuu0123/erd-go/)
* [mscgen](http://www.mcternan.me.uk/mscgen/) was replaced by [mscgen_js](https://github.com/mscgenjs/mscgenjs-cli)

Docker Hub: https://hub.docker.com/r/uwebarthel/asciidoctor

---
<sup>[1]</sup> provided by original Asciidoctor Docker Image
