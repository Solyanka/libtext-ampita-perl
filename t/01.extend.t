use strict;
use warnings;
use Test::Base tests => 3;

BEGIN { use_ok('Text::Ampita') };

can_ok 'Text::Ampita', 'extend';

is_deeply(
    Text::Ampita->extend(
        {'a' => 'A', 'b' => 'B'},
        '.c' => {'c' => 'C', 'd' => 'D'},
    ),
    {'a' => 'A', 'b' => 'B', '.c c' => 'C', '.c d' => 'D'},
    'extend',
);

