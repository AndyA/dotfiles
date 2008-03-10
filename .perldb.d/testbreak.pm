package DB::TestBreak;
our @ISA = qw( DB::Plugin );

print "Test breakpoints enabled\n";

my @testbreak = ();

# Monkeypatch cmd_b (set breakpoint)
my $cmd_b = \&DB::cmd_b;
*DB::cmd_b = sub {
    my ( $cmd, $line, $dbline ) = @_;
    if ( $line =~ /\s*#\s*(\d+(?:\s*,\s*\d+)*)$/ ) {
        my %seen;
        @testbreak = grep { !$seen{$_}++ }
          sort { $a <=> $b } ( split( /\s*,\s*/, $1 ), @testbreak );
        print join( ', ', @testbreak ), "\n";
    }
    else {
        $cmd_b->( @_ );
    }
};

DB::add_handler( __PACKAGE__->new );

sub watchfunction {
    my $self = shift;
    if ( @testbreak && exists $INC{'Test/Builder.pm'} ) {
        my $next
          = ( $self->{tb} ||= Test::Builder->new )->current_test + 1;
        if ( $next >= $testbreak[0] ) {
            shift @testbreak while @testbreak && $next >= $testbreak[0];

            my $depth = 1;
            while ( 1 ) {
                my ( $package, $file, $line ) = caller $depth;
                last unless defined $package;
                last unless $package =~ /^(?:Test|DB)\b/;
                $depth++;
            }
            $DB::stack[ -$depth ] = 1;
        }
    }
    return;
}
