use strict;
use warnings;

use lib 'inc';

use Module::Build;
use MyBuilder;

my $builder = MyBuilder->new(
    module_name       => '[% module.name %]',
    license           => 'perl',
    dist_author       => '[% author.name %] <[% author.email %]>',
    dist_version_from => 'lib/[% module.file %]',
    requires          => {
        'Test::More' => 0,
    },
    add_to_cleanup => ['[% module.dist %]-*'],
);

$builder->create_build_script();
