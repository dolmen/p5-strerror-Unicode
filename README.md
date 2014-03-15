
Test cases for $! issue on non-ASCII locales
============================================

### The issue

`"$!"` and `POSIX::strerror()` return localized strings based on `LC_MESSAGE`,
even if `POSIX::setlocale()` has not been called explicitely.
As the text is locale dependent, its encoding is also locale dependent. But
Perl 5 just returns a raw bytes string instead of a characters string. When the
error message contains non-ASCII characters, it leaves to the program
author to translate the text to an Unicode string before combining the error
message with other texts. If it doesn't and the program output is properly
setup to encode its output, the user may get mojibake.

    use open ':locale', ':std';  # use LC_CTYPE for output
    use Errno qw<EINTR>;
    use POSIX qw<setlocale strerror LC_MESSAGES>;

    setlocale(LC_MESSAGES, 'fr_FR.UTF-8');

    printf "EINTR: %s\n", strerror(EINTR);
    printf "EINTR: %s\n", do { local $! = EINTR; "$!" };

Unfortunately, the translation process is quite tedious to do.

Compare this:

    "$!"

to:

    do {
	use POSIX ();
	use I18N::Langinfo ();
	use Encode ();

	my $msg = "$!";
	my $lc_ctype = POSIX::setlocale(POSIX::LC_CTYPE());
	POSIX::setlocale(POSIX::LC_CTYPE(), POSIX::setlocale(POSIX::LC_MESSAGES()));
	my $codeset = iI18N::Langinfo::langinfo(I18N::Langinfo::CODESET());
	POSIX::setlocale(POSIX::LC_CTYPE(), $lc_ctype);

	Encode::decode($codeset, $msg)
    }

`$!` is a short variable name, meant to ease the reporting of errors.
This complexity completely goes against the aim.

As this issue is not visible to english locales, this issue is very old, as old
as Unicode support in Perl.

#### Win32

Win32 does not seem to be affected by this issue: [`strerror()`](http://msdn.microsoft.com/en-us/library/zc53h9bh.aspx)
messages in MSVCRT does not appear to be localized and returns English ASCII strings even on French Windows 7.

TODO: check if `_wcserror()` behaves differently and returns localized strings.

### Proposed solution

Instead Perl 5 should transparently decode the error messages from the codeset
of LC_MESSAGES to make a proper Unicode string.

Every call to `strerror()` must be wrapped, and every usage of `strerror()` must
take into account that the returned value is Unicode.

### Test cases

* [simple.pl](simple.pl)
* [strerror.pl](strerror.pl)
* [err-8bits.pl](err-8bits.pl)
