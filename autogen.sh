REQUIRED_AUTOMAKE_VERSION=1.9 
REQUIRED_YELP_TOOLS_VERSION=3.1.1
REQUIRED_GETTEXT_VERSION=0.12
REQUIRED_INTLTOOL_VERSION=0.40.4

test -n "$srcdir" || srcdir=$(dirname "$0")
test -n "$srcdir" || srcdir=.
(
  cd "$srcdir" &&
  AUTOPOINT='intltoolize --automake --copy' autoreconf -fiv -Wall
) || exit
test -n "$NOCONFIGURE" || "$srcdir/configure" --enable-maintainer-mode "$@"
