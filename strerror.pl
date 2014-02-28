#!/usr/bin/env perl
use strict;
use warnings;

use Errno 'EINTR';
use POSIX qw<strerror setlocale LC_MESSAGES LC_CTYPE>;
use I18N::Langinfo 'langinfo';
use Encode 'decode';

use open ':locale', ':std';


my @meth = (
    'strerror(EINTR)' => sub { strerror(EINTR) },
    '"$!"'            => sub { local $! = EINTR; "$!" },
);


sub show_EINTR
{
    my $locale = shift;

    # Extract the CODESET of LC_MESSAGES
    my $lc_ctype = setlocale(LC_CTYPE);
    setlocale(LC_CTYPE, setlocale(LC_MESSAGES));
    my $codeset = langinfo(I18N::Langinfo::CODESET());
    # Restore LC_CTYPE
    setlocale(LC_CTYPE, $lc_ctype);

    print "[Locale: $locale  CodeSet: $codeset]\n";

    for(my $i=0; $i<$#meth; $i+=2) {
	my $msg = $meth[$i+1]->();
	printf "      Raw %15s: %s\n", $meth[$i], $msg;
	printf "  Decoded %15s: %s\n", $meth[$i], decode($codeset, $msg);
    }
}


show_EINTR('default ('.setlocale(LC_MESSAGES).')');


# Requires fr_FR.UTF8 locale
foreach my $locale (qw<POSIX fr_FR.UTF-8 de_DE.UTF-8>) {
    setlocale(LC_MESSAGES, $locale);
    show_EINTR($locale);
}
