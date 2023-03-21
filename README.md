# Asciidoctor &mdash; multi platform Edition

The goal of this project is to build a multi platform (especially armv7) Docker image based on the original [Asciidoctor Base/Original &mdash; multi platform Edition](https://github.com/barthel/docker-asciidoctor-base) and adding the following extra diagram tools:

* [ASCIIToSVG](https://github.com/asciitosvg/asciitosvg)
* [blockdiag/blockdiag](https://github.com/blockdiag/blockdiag)
* [blockdiag/actdiag](https://github.com/blockdiag/actdiag)
* [blockdiag/nwdiag](https://github.com/blockdiag/nwdiag)
* [blockdiag/seqdiag](https://github.com/blockdiag/seqdiag)
* [imagemagick for meme](https://asciidoctor.org/docs/asciidoctor-diagram/#meme)
* [mermaid](https://github.com/mermaid-js/mermaid-cli)
* [erd-go](https://github.com/kaishuu0123/erd-go/)

## ⚠️ Note

The following diagramming tools are not installed because there is no executable file for all supported platforms:

* [erd](https://github.com/BurntSushi/erd) was replaced by [erd-go](https://github.com/kaishuu0123/erd-go/)
* [mscgen](http://www.mcternan.me.uk/mscgen/)


Docker Hub: https://hub.docker.com/r/uwebarthel/asciidoctor
