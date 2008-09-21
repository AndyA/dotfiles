package DB::TextMate;
our @ISA = qw( DB::Plugin );
use File::Spec;

unless ( $^O eq 'darwin' ) {
  print "TextMate support disabled (not MacOS)\n";
  exit;
}
eval q{ use TextMate::JumpTo qw(jumpto) };
if ( $@ ) {
  print "TextMate support disabled (TextMate::JumpTo unavailable)\n";
  exit;
}

DB::add_handler( __PACKAGE__->new );
print "TextMate support enabled\n";

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
