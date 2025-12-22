COMPILE=typst
TARGET=repo
ROOT=..

CLASSNO=-final

build: $(TARGET).typ ../template.typ ../bxbibwrite.typ
	$(COMPILE) compile $(TARGET).typ --root $(ROOT) body.pdf && \
		pdfunite title.pdf body.pdf report$(CLASSNO).pdf

.PHONY: build
