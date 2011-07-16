use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Ampita',
    AUTHOR              => 'MIZUTANI Tociyuki <tociyuki@gmail.com>',
    VERSION_FROM        => 'lib/Text/Ampita.pm',
    ABSTRACT_FROM       => 'lib/Text/Ampita.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::Base' => 0,
        'Encode' => 0,
        'Carp' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
