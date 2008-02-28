# config.pl

use strict;
use warnings;

sub find_perls {

}

set_config(
    dists => [
        'HTML::Tiny' => {
            source => {
                type => 'svn',
                url =>
                  'http://svn.hexten.net/andy/Perl/HTML/HTML-Tiny/trunk',
            },
            scripts => ['makefile_pl'],
        }
    ],
    scripts => {
        makefile_pl => {
            precondition => sub {
                -f 'Makefile.PL';
            },
            steps => [
                '%PERL% Makefile.PL',
                'make',
                'make test',
                'make distclean',
            ],
        },
    },
    env => {
        PERL => {
            class => 'Test::SmokeStack::Perl',

        },
    }
);
