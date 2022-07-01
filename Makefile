# Targets:
#   default   Build variable font and package it as a zip file
#   var       Build variable font (in build/font/var)
#   all       Build all fonts; variable and static instances
#   install   Build & install variable font in ~/Library/Fonts/
#   clean     Remove build products and temporary build files
#   reset     Like clean but also resets toolchain
#
# FAM: plain text family name (can contain spaces)
# FAMID: source file family name (no spaces, ASCII only)
FAM   := Inter Tight
FAMID := InterTight

SRCDIR     := $(abspath $(lastword $(MAKEFILE_LIST))/..)
FONTDIR    := build/fonts
UFODIR     := build/ufo
BIN        := $(SRCDIR)/build/venv/bin
VENV       := build/venv/bin/activate
VERSION    := $(shell cat version.txt)
MAKEFILE   := $(lastword $(MAKEFILE_LIST))
INSTALLDIR := $(HOME)/Library/Fonts
ZIP_FILE   := $(PWD)/build/$(FAMID)-$(shell date '+%Y%m%d-%H%M%S').zip

export PATH := $(BIN):$(PATH)

default: zip

# ---------------------------------------------------------------------------------
# intermediate sources

$(UFODIR)/%.glyphs: src/%.glyphspackage | $(UFODIR) venv
	. $(VENV) ; build/venv/bin/glyphspkg -o $(dir $@) $^

src/features: $(wildcard src/features/*)
	@touch "$@"
	@true
$(UFODIR)/features: src/features
	@mkdir -p $(UFODIR)
	@rm -f $(UFODIR)/features
	@ln -s ../../src/features $(UFODIR)/features

$(UFODIR)/%.designspace: $(UFODIR)/%.glyphs $(UFODIR)/features | venv
	. $(VENV) ; fontmake -o ufo -g $< --designspace-path $@ \
		--master-dir $(UFODIR) --instance-dir $(UFODIR)
	. $(VENV) ; python tools/postprocess-designspace.py $@

# master UFOs are byproducts of building .designspace
$(UFODIR)/%-Black.ufo:       $(UFODIR)/%.designspace
	touch $@
$(UFODIR)/%-BlackItalic.ufo: $(UFODIR)/%.designspace
	touch $@
$(UFODIR)/%-Regular.ufo:     $(UFODIR)/%.designspace
	touch $@
$(UFODIR)/%-Italic.ufo:      $(UFODIR)/%.designspace
	touch $@
$(UFODIR)/%-Thin.ufo:        $(UFODIR)/%.designspace
	touch $@
$(UFODIR)/%-ThinItalic.ufo:  $(UFODIR)/%.designspace
	touch $@

# instance UFOs are generated on demand
$(UFODIR)/%-Light.ufo:            $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Light"
$(UFODIR)/%-LightItalic.ufo:      $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Light Italic"
$(UFODIR)/%-ExtraLight.ufo:       $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Extra Light"
$(UFODIR)/%-ExtraLightItalic.ufo: $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Extra Light Italic"
$(UFODIR)/%-Medium.ufo:           $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Medium"
$(UFODIR)/%-MediumItalic.ufo:     $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Medium Italic"
$(UFODIR)/%-SemiBold.ufo:         $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Semi Bold"
$(UFODIR)/%-SemiBoldItalic.ufo:   $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Semi Bold Italic"
$(UFODIR)/%-Bold.ufo:             $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Bold"
$(UFODIR)/%-BoldItalic.ufo:       $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Bold Italic"
$(UFODIR)/%-ExtraBold.ufo:        $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Extra Bold"
$(UFODIR)/%-ExtraBoldItalic.ufo:  $(UFODIR)/%.designspace | venv
	. $(VENV) ; fontmake -o ufo -m $< --output-path $@ -i "$(FAM) Extra Bold Italic"

# make sure intermediate files are not rm'd by make
.PRECIOUS: \
	$(UFODIR)/$(FAMID)-Black.ufo \
	$(UFODIR)/$(FAMID)-BlackItalic.ufo \
	$(UFODIR)/$(FAMID)-Regular.ufo \
	$(UFODIR)/$(FAMID)-Italic.ufo \
	$(UFODIR)/$(FAMID)-Thin.ufo \
	$(UFODIR)/$(FAMID)-ThinItalic.ufo \
	$(UFODIR)/$(FAMID)-Light.ufo \
	$(UFODIR)/$(FAMID)-LightItalic.ufo \
	$(UFODIR)/$(FAMID)-ExtraLight.ufo \
	$(UFODIR)/$(FAMID)-ExtraLightItalic.ufo \
	$(UFODIR)/$(FAMID)-Medium.ufo \
	$(UFODIR)/$(FAMID)-MediumItalic.ufo \
	$(UFODIR)/$(FAMID)-SemiBold.ufo \
	$(UFODIR)/$(FAMID)-SemiBoldItalic.ufo \
	$(UFODIR)/$(FAMID)-Bold.ufo \
	$(UFODIR)/$(FAMID)-BoldItalic.ufo \
	$(UFODIR)/$(FAMID)-ExtraBold.ufo \
	$(UFODIR)/$(FAMID)-ExtraBoldItalic.ufo \
	$(UFODIR)/$(FAMID).glyphs \
	$(UFODIR)/$(FAMID).designspace

# ---------------------------------------------------------------------------------
# products

$(FONTDIR)/static/%.otf: $(UFODIR)/%.ufo | $(FONTDIR)/static venv
	. $(VENV) ; fontmake -u $< -o otf --output-path $@ \
		--overlaps-backend pathops --production-names

$(FONTDIR)/static/%.ttf: $(UFODIR)/%.ufo | $(FONTDIR)/static venv
	. $(VENV) ; fontmake -u $< -o ttf --output-path $@ \
		--overlaps-backend pathops --production-names

$(FONTDIR)/static-hinted/%.ttf: $(FONTDIR)/static/%.ttf | $(FONTDIR)/static-hinted venv
	. $(VENV) ; python $(PWD)/build/venv/lib/python/site-packages/ttfautohint \
		--no-info "$<" "$@"

$(FONTDIR)/var/%.var.ttf: $(UFODIR)/%.designspace | $(FONTDIR)/var venv
	. $(VENV) ; fontmake -o variable -m $< --output-path $@ \
		--overlaps-backend pathops --production-names
	. $(VENV) ; python tools/postprocess-vf.py $@
	. $(VENV) ; gftools fix-unwanted-tables -t MVAR $@

$(FONTDIR)/var/%.var.otf: $(UFODIR)/%.designspace | $(FONTDIR)/var venv
	. $(VENV) ; fontmake -o variable-cff2 -m $< --output-path $@ \
		--overlaps-backend pathops --production-names

%.woff2: %.ttf | venv
	. $(VENV) ; tools/woff2 compress -o "$@" "$<"

$(FONTDIR)/static:
	mkdir -p $@
$(FONTDIR)/static-hinted:
	mkdir -p $@
$(FONTDIR)/var:
	mkdir -p $@
$(UFODIR):
	mkdir -p $@

# ---------------------------------------------------------------------------------

static_otf: \
	$(FONTDIR)/static/$(FAMID)-Black.otf \
	$(FONTDIR)/static/$(FAMID)-BlackItalic.otf \
	$(FONTDIR)/static/$(FAMID)-Regular.otf \
	$(FONTDIR)/static/$(FAMID)-Italic.otf \
	$(FONTDIR)/static/$(FAMID)-Thin.otf \
	$(FONTDIR)/static/$(FAMID)-ThinItalic.otf \
	$(FONTDIR)/static/$(FAMID)-Light.otf \
	$(FONTDIR)/static/$(FAMID)-LightItalic.otf \
	$(FONTDIR)/static/$(FAMID)-ExtraLight.otf \
	$(FONTDIR)/static/$(FAMID)-ExtraLightItalic.otf \
	$(FONTDIR)/static/$(FAMID)-Medium.otf \
	$(FONTDIR)/static/$(FAMID)-MediumItalic.otf \
	$(FONTDIR)/static/$(FAMID)-SemiBold.otf \
	$(FONTDIR)/static/$(FAMID)-SemiBoldItalic.otf \
	$(FONTDIR)/static/$(FAMID)-Bold.otf \
	$(FONTDIR)/static/$(FAMID)-BoldItalic.otf \
	$(FONTDIR)/static/$(FAMID)-ExtraBold.otf \
	$(FONTDIR)/static/$(FAMID)-ExtraBoldItalic.otf

static_ttf: \
	$(FONTDIR)/static/$(FAMID)-Black.ttf \
	$(FONTDIR)/static/$(FAMID)-BlackItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-Regular.ttf \
	$(FONTDIR)/static/$(FAMID)-Italic.ttf \
	$(FONTDIR)/static/$(FAMID)-Thin.ttf \
	$(FONTDIR)/static/$(FAMID)-ThinItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-Light.ttf \
	$(FONTDIR)/static/$(FAMID)-LightItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-ExtraLight.ttf \
	$(FONTDIR)/static/$(FAMID)-ExtraLightItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-Medium.ttf \
	$(FONTDIR)/static/$(FAMID)-MediumItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-SemiBold.ttf \
	$(FONTDIR)/static/$(FAMID)-SemiBoldItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-Bold.ttf \
	$(FONTDIR)/static/$(FAMID)-BoldItalic.ttf \
	$(FONTDIR)/static/$(FAMID)-ExtraBold.ttf \
	$(FONTDIR)/static/$(FAMID)-ExtraBoldItalic.ttf

static_ttf_hinted: \
	$(FONTDIR)/static-hinted/$(FAMID)-Black.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-BlackItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Regular.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Italic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Thin.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-ThinItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Light.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-LightItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraLight.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraLightItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Medium.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-MediumItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-SemiBold.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-SemiBoldItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-Bold.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-BoldItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraBold.ttf \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraBoldItalic.ttf

static_web: \
	$(FONTDIR)/static/$(FAMID)-Black.woff2 \
	$(FONTDIR)/static/$(FAMID)-BlackItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-Regular.woff2 \
	$(FONTDIR)/static/$(FAMID)-Italic.woff2 \
	$(FONTDIR)/static/$(FAMID)-Thin.woff2 \
	$(FONTDIR)/static/$(FAMID)-ThinItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-Light.woff2 \
	$(FONTDIR)/static/$(FAMID)-LightItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-ExtraLight.woff2 \
	$(FONTDIR)/static/$(FAMID)-ExtraLightItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-Medium.woff2 \
	$(FONTDIR)/static/$(FAMID)-MediumItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-SemiBold.woff2 \
	$(FONTDIR)/static/$(FAMID)-SemiBoldItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-Bold.woff2 \
	$(FONTDIR)/static/$(FAMID)-BoldItalic.woff2 \
	$(FONTDIR)/static/$(FAMID)-ExtraBold.woff2 \
	$(FONTDIR)/static/$(FAMID)-ExtraBoldItalic.woff2

static_web_hinted: \
	$(FONTDIR)/static-hinted/$(FAMID)-Black.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-BlackItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Regular.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Italic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Thin.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-ThinItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Light.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-LightItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraLight.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraLightItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Medium.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-MediumItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-SemiBold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-SemiBoldItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-Bold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-BoldItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraBold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMID)-ExtraBoldItalic.woff2

var: $(FONTDIR)/var/$(FAMID).var.ttf

var_web: $(FONTDIR)/var/$(FAMID).var.woff2

web: var_web static_web

all:        static_otf static_ttf static_ttf_hinted static_web static_web_hinted \
            var var_web

.PHONY: all static_otf static_ttf static_ttf_hinted static_web static_web_hinted \
            var var_web web

# ---------------------------------------------------------------------------------

zip: $(ZIP_FILE)

$(ZIP_FILE): $(FONTDIR)/var/$(FAMID).var.ttf
	rm -rf build/tmp/zip
	mkdir -p build/tmp/zip
	cp build/fonts/var/$(FAMID).var.ttf build/tmp/zip/$(FAMID).var.ttf
	cd build/tmp/zip ; zip -q -X -r "$@" *
	rm -rf build/tmp/zip
	[ -t 0 -a $$(uname -s) = "Darwin" ] && open --reveal "$@"

.PHONY: zip

# ---------------------------------------------------------------------------------

install: $(INSTALLDIR)/$(FAMID).var.ttf

$(INSTALLDIR)/%.otf: $(FONTDIR)/static/%.otf | $(INSTALLDIR)
	cp -a $^ $@

$(INSTALLDIR)/%.var.ttf: $(FONTDIR)/var/%.var.ttf | $(INSTALLDIR)
	cp -a $^ $@

$(INSTALLDIR):
	mkdir -p $@

.PHONY: install

# ---------------------------------------------------------------------------------

clean:
	rm -rf build/tmp build/fonts build/ufo

.PHONY: clean

# ---------------------------------------------------------------------------------
# initialize toolchain

venv: build/venv/config.stamp

build/venv/config.stamp: requirements.txt
	@mkdir -p build
	test -d build/venv || python3 -m venv build/venv
	. $(VENV) ; pip install -Ur requirements.txt
	rm -f build/venv/lib/python
	ln -sf $$(basename $$(readlink build/venv/bin/python)) build/venv/lib/python
	touch $@

reset: clean
	rm -rf build/venv

.PHONY: venv reset
