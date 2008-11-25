package DB::TextMate;
use File::Spec;
our @ISA = qw( DB::Plugin );

if ( $^O eq 'darwin' ) {
  eval q{ use TextMate::JumpTo qw(jumpto) };
  if ( !$@ ) {
    DB::add_handler( __PACKAGE__->new );
    print "TextMate support enabled\n";
  }
  else {
    print "TextMate support disabled (TextMate::JumpTo unavailable)\n";
  }
}
else {
  print "TextMate support disabled (not MacOS)\n";
}

sub afterinit {
  my $self = shift;
  chomp( $self->{base_dir} = `pwd` );

  $DB::option{animate} = 0;
  push @DB::options, 'animate';
}

sub watchfunction {
  my ( $self, $package, $file, $line ) = @_;
  return unless $DB::single || $DB::signal || $DB::option{animate};
  return if $file =~ m{/perl5db[.]pl$};

  local $DB::trace = 0;

  # Doesn't really work
  if ( $file =~ /^\(eval\s+\d+\)\[(.+?):(\d+)\]/ ) {
    $file = $1;
    $line += $2 - 1;
  }

  jumpto(
    file => File::Spec->rel2abs( $file, $self->{base_dir} ),
    line => $line,
    bg   => 1
  );

  return 1;
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
