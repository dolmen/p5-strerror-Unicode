#!/usr/bin/env perl
use strict;
use warnings;

use Errno 'EINTR';
use POSIX qw<strerror setlocale LC_MESSAGES LC_CTYPE>;
use I18N::Langinfo 'langinfo';
use Encode 'decode';

use open ':locale', ':std';

sub show_EINTR
{
    my $locale = shift;
    print "[Locale: $locale]\n";
    # Raw values
    printf("  strerror(EINTR): %s\n", strerror(EINTR));
    $! = EINTR;
    printf("  \"\$!\":            %s\n", "$!");

    # Converted using locale information
    my $lc_ctype_orig = setlocale(LC_CTYPE);
    setlocale(LC_CTYPE, setlocale(LC_MESSAGES));
    my $codeset = langinfo(I18N::Langinfo::CODESET());
    printf("  Decoding from %s...\n", $codeset);
    printf("  strerror(EINTR): %s\n", decode($codeset, strerror(EINTR)));
    $! = EINTR;
    printf("  \"\$!\":            %s\n", decode($codeset, "$!"));
    setlocale(LC_CTYPE, $lc_ctype_orig);
}


show_EINTR('default ('.setlocale(LC_MESSAGES).', CODESET='.langinfo(I18N::Langinfo::CODESET()).')');


# Requires fr_FR.UTF8 locale
foreach my $locale (qw<POSIX fr_FR.UTF-8 de_DE.UTF-8>) {
    setlocale(LC_MESSAGES, $locale);
    show_EINTR($locale);
}
