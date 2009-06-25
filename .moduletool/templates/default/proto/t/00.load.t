use Test::More tests => 1;

BEGIN {
  use_ok( '[% module.name %]' );
}

diag( "Testing [% module.name %] $[% module.name %]::VERSION" );
