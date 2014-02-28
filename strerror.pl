#!/usr/bin/env perl
use strict;
use warnings;

use Errno ();
use POSIX qw<strerror setlocale LC_MESSAGES LC_CTYPE>;
use I18N::Langinfo 'langinfo';
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

    # Extract the CODESET of LC_MESSAGES
    my $lc_ctype = setlocale(LC_CTYPE);
    setlocale(LC_CTYPE, setlocale(LC_MESSAGES));
    my $codeset = langinfo(I18N::Langinfo::CODESET());
    # Restore LC_CTYPE
    setlocale(LC_CTYPE, $lc_ctype);

    print "[Locale: $locale  CodeSet: $codeset]\n";

    for(my $i=0; $i<$#$tests; $i+=2) {
	my $msg = $tests->[$i+1]->();
	printf "      Raw %15s: %s\n", $tests->[$i], $msg;
	printf "  Decoded %15s: %s\n", $tests->[$i], decode($codeset, $msg);
    }
}


test('default ('.setlocale(LC_MESSAGES).')', \@TESTS);


# Requires fr_FR.UTF8 locale
foreach my $locale (qw<POSIX fr_FR.UTF-8 de_DE.UTF-8>) {
    setlocale(LC_MESSAGES, $locale);
    test($locale, \@TESTS);
}
