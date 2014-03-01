#!/usr/bin/env perl

use open ':locale', ':std';  # use LC_CTYPE for output
use Errno qw<EINTR>;
use POSIX qw<setlocale strerror LC_MESSAGES>;

printf "Locale: %s\n", setlocale(LC_MESSAGES);

printf "EINTR: %s\n", strerror(EINTR);
printf "EINTR: %s\n", do { local $! = EINTR; "$!" };
