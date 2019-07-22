BIN ?= shellspec
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

all: shellspec

install:
	install -d $(LIBDIR)/$(BIN)
	cp -r shellspec lib libexec $(LIBDIR)/$(BIN)
	install -D bin/shellspec.stub $(BINDIR)/$(BIN)

uninstall:
	rm -rf $(LIBDIR)/$(BIN) $(BINDIR)/$(BIN)

package:
	contrib/make_package_json.sh > package.json

test:
	./shellspec
