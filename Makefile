PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

GENGETOPTIONS := gengetoptions
OPTPARSERDIR := lib/libexec/optparser

.PHONY: coverage test dist build release

all: test check

dist: LICENSE shellspec lib libexec
	tar -czf shellspec-dist.tar.gz $^ --transform 's,^,shellspec/,'

install:
	install -d "$(BINDIR)" "$(LIBDIR)"
	install stub/shellspec "$(BINDIR)/shellspec"
	find lib libexec -type d -exec install -d "$(LIBDIR)/shellspec/{}" \;
	find LICENSE lib -type f -exec install -m 644 {} "$(LIBDIR)/shellspec/{}" \;
	find shellspec libexec -type f -exec install {} "$(LIBDIR)/shellspec/{}" \;

uninstall:
	rm -rf "$(BINDIR)/shellspec" "$(LIBDIR)/shellspec"

package:
	contrib/make_package_json.sh > package.json

# Take in to retest getoptions in various shells
takein_getoptions:
	cp ../getoptions/lib/getoptions_*.sh lib
	cp ../getoptions/spec/getoptions_*_spec.sh spec

optparser:
	@printf "getoptions: "
	@$(GENGETOPTIONS) --version
	$(GENGETOPTIONS) parser --indent=2 --shellcheck \
		-f $(OPTPARSERDIR)/parser_definition.sh \
	        parser_definition optparser_parse SHELLSPEC optparser_error \
		> $(OPTPARSERDIR)/parser_definition_generated.sh

demo:
	ttyrec -e "ghostplay contrib/demo.sh"
	seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o docs/demo.gif
	gifsicle -i docs/demo.gif -O3 -o docs/demo.gif

coverage:
	contrib/coverage.sh --pull

check:
	contrib/check.sh --pull

metrics:
	contrib/metrics.sh

build:
	contrib/build.sh .dockerhub/Dockerfile         shellspec
	contrib/build.sh .dockerhub/Dockerfile         shellspec kcov
	contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian
	contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian kcov
	contrib/build.sh .dockerhub/Dockerfile.scratch shellspec-scratch

test:
	./shellspec

test_all:
	contrib/all.sh shellspec

test_in_docker:
	contrib/test_in_docker.sh --pull dockerfiles/* -- shellspec -j 2

release:
	contrib/release.sh
