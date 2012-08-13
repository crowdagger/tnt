# Makefile.am

SUBDIRS = cards icons cards_marseille

desktopdir = $(datadir)/applications
desktop_in_files=tnt.desktop.in.in
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

uidir = $(pkgdatadir)
ui_DATA= app_menu.ui

EXTRA_DIST = \
	$(desktop_in_files) $(ui_DATA)

CLEANFILES = \
	$(desktop_DATA)
