use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Stormpath',
    AUTHOR              => 'Tyson Maly <tvmaly@cpan.org>',
    VERSION_FROM        => 'lib/Stormpath.pm',
    ABSTRACT_FROM       => 'lib/Stormpath.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Stormpath-*' },
);
