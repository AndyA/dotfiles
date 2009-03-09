use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Foo::Bar',
    license           => 'perl',
    dist_author       => 'Andy Armstrong <andy@hexten.net>',
    dist_version_from => 'lib/Foo/Bar.pm',
    requires          => {
        'Test::More' => 0,
    },
    add_to_cleanup => ['Foo-Bar-*'],
);

$builder->create_build_script();
