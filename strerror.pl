#!/usr/bin/env perl
use strict;
use warnings;

use Errno ();
use POSIX qw<strerror setlocale LC_MESSAGES LC_CTYPE>;
use Encode 'decode';

use open ':locale', ':std';

# Test with each errno given in @ARGV
@ARGV = qw<EINTR> unless @ARGV;

# List of tests:
#   name => sub
my @TESTS = map
{
    my $str = $_;
    my $num = do { no strict 'refs'; &{"Errno::$str"} };

    # Push 4 elements in @TESTS for each errno
    (
	"strerror($str)" => sub { strerror($num) },
	'"$!"'           => sub { local $! = $num; "$!" },
    )
} @ARGV;



sub test
{
    my ($locale, $tests) = @_;

    # Win32 doesn't have I18N::Langinfo and POSIX::LC_MESSAGES
    my $codeset;
    eval {
        # Extract the CODESET of LC_MESSAGES
        my $lc_ctype = setlocale(LC_CTYPE);
        setlocale(LC_CTYPE, setlocale(POSIX::LC_MESSAGES));
        $codeset = I18N::Langinfo::langinfo(I18N::Langinfo::CODESET());
        # Restore LC_CTYPE
        setlocale(LC_CTYPE, $lc_ctype);
    };
    $codeset ||= '';

    print "[Locale: $locale  CodeSet: $codeset]\n";

    for(my $i=0; $i<$#$tests; $i+=2) {
	my $msg = $tests->[$i+1]->();
	printf "  %20s     raw: %s\n", $tests->[$i], $msg;
	printf "  %20s decoded: %s\n", $tests->[$i], decode($codeset, $msg) if $codeset;
    }
}

eval { require I18N::Langinfo };

test('default ('.(eval { setlocale(POSIX::LC_MESSAGES) } || 'LC_MESSAGES undef').')', \@TESTS);


exit unless defined &POSIX::LC_MESSAGES;

# Requires fr_FR.UTF8 locale
foreach my $locale (qw<POSIX fr_FR.UTF-8 de_DE.UTF-8>) {
    setlocale(LC_MESSAGES, $locale);
    if ($!) {
	if ($!{'ENOENT'}) {
	    print STDERR "Skipping '$locale': locale not supported\n";
	} else {
	    printf STDERR "Skipping '%s': locale error %d: %s\n", $locale, 0+$!, "$!";
	}
	next;
    }
    test($locale, \@TESTS);
}
