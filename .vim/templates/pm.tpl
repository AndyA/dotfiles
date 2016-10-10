package Foo;

our $VERSION = "0.01";

use v5.10;

use Moose;

=head1 NAME

Foo - do something

=cut

no Moose;
__PACKAGE__->meta->make_immutable;

# vim:ts=2:sw=2:sts=2:et:ft=perl
