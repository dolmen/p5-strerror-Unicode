#!/usr/bin/env perl
use strict;
use warnings;



use Errno ();
use POSIX qw<strerror setlocale LC_MESSAGES LC_CTYPE>;
use I18N::Langinfo 'langinfo';
use Encode 'decode';

use open ':locale', ':std';

# Codeset for LC_MESSAGES
my $codeset;
{
    my $lc_ctype = setlocale(LC_CTYPE);
    setlocale(LC_CTYPE, setlocale(LC_MESSAGES));
    $codeset = langinfo(I18N::Langinfo::CODESET());
    setlocale(LC_CTYPE, $lc_ctype);
}

foreach my $err (@{$Errno::EXPORT_TAGS{'POSIX'}}) {
    my $num = do { no strict 'refs'; &{"Errno::$err"} };
    my $msg = strerror($num);
    next unless $msg =~ /[^\x01-\x7f]/s; # skip ASCII
    printf "%15s: %s\n", $err, decode($codeset, $msg);
}

