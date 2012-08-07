GNOMEDOC=`which yelp-build`
if test -z $GNOMEDOC; then
echo "Error: yelp-build (used for building the documentation) is missing."
echo "Please install the yelp-tools package."
exit 1
fi

test -n "$srcdir" || srcdir=$(dirname "$0")
test -n "$srcdir" || srcdir=.
(
  cd "$srcdir" &&
  AUTOPOINT='intltoolize --automake --copy' autoreconf -fiv -Wall
) || exit
test -n "$NOCONFIGURE" || "$srcdir/configure" --enable-maintainer-mode "$@"
