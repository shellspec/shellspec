PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

.PHONY: coverage

all: shellspec

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

demo:
	ttyrec -e "ghostplay contrib/demo.sh"
	seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o docs/demo.gif
	gifsicle -i docs/demo.gif -O3 -o docs/demo.gif

coverage:
	contrib/coverage.sh

check:
	contrib/check.sh --pull

build:
	contrib/build.sh .dockerhub/Dockerfile         shellspec
	contrib/build.sh .dockerhub/Dockerfile         shellspec kcov
	contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian
	contrib/build.sh .dockerhub/Dockerfile.debian  shellspec-debian kcov
	contrib/build.sh .dockerhub/Dockerfile.scratch shellspec-scratch

testall:
	contrib/test_in_docker.sh dockerfiles/* -- shellspec -j 2

test:
	./shellspec

release:
	contrib/release.sh
