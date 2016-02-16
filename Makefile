## This Makefile works with fpm to generate a set of installation packages given a directory
## which looks like what you want installed.
## It uses the git origin url to determine the vendor, maintainer, and url for each package.

## What version is this package?
VERSION=0.2
NAME=jrun

## Automatically figure out a bunch of stuff:
SOURCES=$(shell find src -type f)
ORIGIN=$(shell git config --get remote.origin.url)
DEB_FILE=$(NAME)_$(VERSION)_all.deb
OSX_PKG=$(NAME)-$(VERSION).pkg

all : $(DEB_FILE) $(OSX_PKG)

clean :
	rm -f $(DEB_FILE)
	rm -f $(OSX_PKG)

$(DEB_FILE) : $(SOURCES) Makefile
	rm -f $@
	fpm -s dir -t deb -n $(NAME) -v $(VERSION) --vendor $(ORIGIN) --maintainer $(ORIGIN) --url $(ORIGIN) -C src -a all 

$(OSX_PKG) : $(SOURCES) Makefile
	rm -f $@
	fpm -s dir -t osxpkg -n $(NAME) -v $(VERSION) --vendor $(ORIGIN) --maintainer $(ORIGIN) --url $(ORIGIN) -C src -a all 
