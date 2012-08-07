# configure.ac

AC_INIT([TnT],[0.3.1])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.16.0])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.35])

pkg_modules="gtk+-3.0 >= 3.4.0 gee-1.0 >= 0.6.0 glib-2.0 >= 2.30.0"
TNT_PACKAGES="--pkg gtk+-3.0 --pkg gee-1.0"
PKG_CHECK_MODULES(TNT, [$pkg_modules])
AC_SUBST(TNT_CFLAGS)
AC_SUBST(TNT_LIBS)
AC_SUBST(TNT_PACKAGES)

GETTEXT_PACKAGE=tnt
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	src/Makefile
  vapi/Makefile
  data/Makefile
  data/cards/Makefile
  po/Makefile.in
  data/tnt.desktop.in
])
AC_OUTPUT
