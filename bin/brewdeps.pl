#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

my @I = `brew list`;
chomp for @I;
my %I = map { $_ => 1 } @I;

while (<>) {
  chomp;
  my ( $pkg, $deps ) = /^(\S+?):\s*(.*)$/;
  next unless $I{$pkg};
  for my $dep ( split /\s+/, $deps ) {
    next unless $I{$dep};
    print "$dep $pkg\n";
  }
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

