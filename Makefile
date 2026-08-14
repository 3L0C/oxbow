# The actual oxbow build is driven by dune. This Makefile exists only to group
# the Sphinx documentation commands so they are easy to remember and
# discoverable from the devshell.

DOCS_DIR   := docs
DOCS_BUILD := $(DOCS_DIR)/_build

help:
	@echo "oxbow documentation targets:"
	@echo "  make docs           - Build the HTML docs"
	@echo "  make docs-html      - Build HTML docs into $(DOCS_BUILD)/html"
	@echo "  make docs-serve     - Build HTML and serve at localhost:8000"
	@echo "  make docs-live      - Live-reload HTML build (sphinx-autobuild)"
	@echo "  make docs-linkcheck - Verify all internal and external links"
	@echo "  make docs-clean     - Remove $(DOCS_BUILD)"
	@echo "  make man            - Regenerate bin/oxctl/oxctl.1"

docs: docs-html

man:
	dune build bin/oxctl/main.exe
	sh bin/oxctl/stitch.sh _build/default/bin/oxctl/main.exe > bin/oxctl/oxctl.1

docs-html:
	sphinx-build -b html $(DOCS_DIR) $(DOCS_BUILD)/html

docs-serve: docs-html
	python3 -m http.server -d $(DOCS_BUILD)/html 8000

docs-live:
	sphinx-autobuild $(DOCS_DIR) $(DOCS_BUILD)/html

docs-linkcheck:
	sphinx-build -b linkcheck $(DOCS_DIR) $(DOCS_BUILD)/linkcheck

docs-clean:
	rm -rf $(DOCS_BUILD)

.PHONY: docs docs-html docs-serve docs-live docs-linkcheck docs-clean man help
