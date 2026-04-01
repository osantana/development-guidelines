BOOK := development-guidelines.adoc
BUILD_DIR := build
HTML_OUT := $(BUILD_DIR)/development-guidelines.html
PDF_OUT := $(BUILD_DIR)/development-guidelines.pdf
PLANTUML := plantuml
PUML_SRCS := $(wildcard diagrams/src/architecture/*.puml)
DIAGRAM_SVGS := $(patsubst diagrams/src/architecture/%.puml,diagrams/rendered/architecture/%.svg,$(PUML_SRCS))
BUILD_DIAGRAM_DIR := $(BUILD_DIR)/diagrams/rendered/architecture
BUILD_DIAGRAM_SVGS := $(patsubst diagrams/rendered/architecture/%.svg,$(BUILD_DIAGRAM_DIR)/%.svg,$(DIAGRAM_SVGS))

.PHONY: all html pdf diagrams clean

all: html pdf

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIAGRAM_DIR):
	mkdir -p $(BUILD_DIAGRAM_DIR)

$(BUILD_DIAGRAM_DIR)/%.svg: diagrams/rendered/architecture/%.svg | $(BUILD_DIAGRAM_DIR)
	cp $< $@

diagrams: $(DIAGRAM_SVGS)

diagrams/rendered/architecture:
	mkdir -p diagrams/rendered/architecture

diagrams/rendered/architecture/%.svg: diagrams/src/architecture/%.puml | diagrams/rendered/architecture
	$(PLANTUML) -tsvg -o ../../rendered/architecture $<

html: $(HTML_OUT)

$(HTML_OUT): $(BOOK) $(wildcard attributes.adoc capitulos/*.adoc) $(DIAGRAM_SVGS) $(BUILD_DIAGRAM_SVGS)
	mkdir -p $(BUILD_DIR)
	asciidoctor $(BOOK) -D $(BUILD_DIR)

pdf: $(PDF_OUT)

$(PDF_OUT): $(BOOK) $(wildcard attributes.adoc capitulos/*.adoc) $(DIAGRAM_SVGS)
	mkdir -p $(BUILD_DIR)
	asciidoctor-pdf $(BOOK) -D $(BUILD_DIR)

clean:
	rm -f $(HTML_OUT) $(PDF_OUT)
	rm -rf diagrams/rendered
