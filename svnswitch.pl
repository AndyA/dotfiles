#!/usr/bin/env perl

use strict;
use warnings;
use File::chdir;

open my $rh, '-|', 'svnroots', '-a' or die "Can't run svnroot ($!)\n";
while ( <$rh> ) {
  chomp;
  my ( $dir, $repo ) = split /\t/, $_, 2;
  if ( $repo =~ m{^http(://svn.hexten.net/\w+)} ) {
    my $from = "http$1";
    my $to   = "https$1";
    local $CWD = $dir;
    print "Switching $dir from $from to $to\n";
    my @cmd = ( 'svn', 'switch', '--relocate', $from, $to );
    print '  ', join( ' ', @cmd ), "\n";
    system @cmd and warn "Failed! ($?)\n";
  }
}
close $rh or die "Failed to run svnroot ($!)\n";

# vim:ts=2:sw=2:sts=2:et:ft=perl

