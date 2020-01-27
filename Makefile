BIN ?= shellspec
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

.PHONY: coverage

all: shellspec

archive: LICENSE shellspec lib libexec
	tar -czf shellspec.tar.gz $^ --transform 's,^,shellspec/,'

install:
	install -d $(LIBDIR)/$(BIN)
	cp -r shellspec lib libexec $(LIBDIR)/$(BIN)
	install -D stub/shellspec $(BINDIR)/$(BIN)

uninstall:
	rm -rf $(LIBDIR)/$(BIN) $(BINDIR)/$(BIN)

package:
	contrib/make_package_json.sh > package.json

demo:
	ttyrec -e "ghostplay contrib/demo.sh"
	seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o docs/demo.gif
	gifsicle -i docs/demo.gif -O3 -o docs/demo.gif

coverage:
	contrib/coverage.sh

check:
	contrib/check.sh

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
