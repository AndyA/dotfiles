use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

WriteMakefile(
    ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
    NAME          => '<MAIN MODULE>',
    AUTHOR        => '<AUTHOR> <<EMAIL>>',
    LICENSE       => 'perl',
    VERSION_FROM  => '<MAIN PM FILE>',
    ABSTRACT_FROM => '<MAIN PM FILE>',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => '<DISTRO>-*' },
);
