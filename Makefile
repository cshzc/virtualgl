all: rr mesademos diags

.PHONY: rr util jpeg mesademos diags clean

rr: util jpeg

rr util jpeg mesademos diags:
	cd $@; $(MAKE); cd ..

clean:
	cd rr; $(MAKE) clean; cd ..; \
	cd util; $(MAKE) clean; cd ..; \
	cd jpeg; $(MAKE) clean; cd ..; \
	cd mesademos; $(MAKE) clean; cd ..; \
	cd diags; $(MAKE) clean; cd ..

TOPDIR=.
include Makerules

##########################################################################
ifeq ($(platform), windows)
##########################################################################

ifeq ($(DEBUG), yes)
WEDIR := $(platform)$(subplatform)\\bind
else
WEDIR := $(platform)$(subplatform)\\bin
endif

dist: rr diags
	$(RM) $(APPNAME).exe
	makensis //DAPPNAME=$(APPNAME) //DVERSION=$(VERSION) \
		//DBUILD=$(BUILD) //DEDIR=$(WEDIR) rr.nsi


##########################################################################
else
##########################################################################

ifeq ($(subplatform),)
RPMARCH = i386
else
RPMARCH = $(ARCH)
endif

ifeq ($(prefix),)
prefix=/usr/local
endif

PACKAGENAME = $(APPNAME)
ifeq ($(subplatform), 64)
PACKAGENAME = $(APPNAME)64
endif

ifeq ($(subplatform), 64)
install: rr
	mkdir -p $(prefix)/bin
	mkdir -p $(prefix)/lib64
	install -m 755 $(EDIR)/rrlaunch64 $(prefix)/bin/rrlaunch64
	install -m 755 $(LDIR)/libhpjpeg.$(SHEXT) $(prefix)/lib64/libhpjpeg.$(SHEXT)
	install -m 755 $(LDIR)/librrfaker.$(SHEXT) $(prefix)/lib64/librrfaker.$(SHEXT)
	echo Install complete.
else
install: rr
	mkdir -p $(prefix)/bin
	mkdir -p $(prefix)/lib
	install -m 755 rr/rrxclient.sh $(prefix)/bin/rrxclient_daemon
	install -m 755 rr/rrxclient_ssl.sh $(prefix)/bin/rrxclient_ssldaemon
	install -m 755 rr/rrxclient_config $(prefix)/bin/rrxclient_config
	install -m 644 rr/rrcert.cnf /etc/rrcert.cnf
	install -m 755 rr/newrrcert $(prefix)/bin/newrrcert
	install -m 755 $(EDIR)/rrlaunch $(prefix)/bin/rrlaunch
	install -m 755 $(EDIR)/rrxclient $(prefix)/bin/rrxclient
	install -m 755 $(LDIR)/libhpjpeg.$(SHEXT) $(prefix)/lib/libhpjpeg.$(SHEXT)
	install -m 755 $(LDIR)/librrfaker.$(SHEXT) $(prefix)/lib/librrfaker.$(SHEXT)
	echo Install complete.
endif

ifeq ($(subplatform), 64)
uninstall:
	$(RM) $(prefix)/bin/rrlaunch64
	$(RM) $(prefix)/lib64/libhpjpeg.$(SHEXT)
	$(RM) $(prefix)/lib64/librrfaker.$(SHEXT)
	echo Uninstall complete.
else
uninstall:
	$(prefix)/bin/rrxclient_daemon stop || echo Client not installed
	$(prefix)/bin/rrxclient_ssldaemon stop || echo Secure client not installed
	$(RM) $(prefix)/bin/rrxclient_daemon
	$(RM) $(prefix)/bin/rrxclient_ssldaemon
	$(RM) $(prefix)/bin/rrxclient_config
	$(RM) /etc/rrcert.cnf
	$(RM) $(prefix)/bin/newrrcert
	$(RM) $(prefix)/bin/rrlaunch
	$(RM) $(prefix)/bin/rrxclient
	$(RM) $(prefix)/lib/libhpjpeg.$(SHEXT)
	$(RM) $(prefix)/lib/librrfaker.$(SHEXT)
	echo Uninstall complete.
endif

ALL: dist mesademos

dist: rr diags $(BLDDIR)/rpms/BUILD $(BLDDIR)/rpms/RPMS
	rm -f $(BLDDIR)/$(PACKAGENAME).$(RPMARCH).rpm; \
	rpmbuild -bb --define "_blddir `pwd`/$(BLDDIR)" --define "_curdir `pwd`" --define "_topdir $(BLDDIR)/rpms" \
		--define "_version $(VERSION)" --define "_build $(BUILD)" --define "_bindir $(EDIR)" \
		--define "_libdir $(LDIR)" --define "_appname $(APPNAME)" --target $(RPMARCH) \
		rr.spec; \
	mv $(BLDDIR)/rpms/RPMS/$(RPMARCH)/$(PACKAGENAME)-$(VERSION)-$(BUILD).$(RPMARCH).rpm $(BLDDIR)/$(PACKAGENAME).$(RPMARCH).rpm

$(BLDDIR)/rpms/BUILD:
	mkdir -p $@

$(BLDDIR)/rpms/RPMS:
	mkdir -p $@

##########################################################################
endif
##########################################################################
