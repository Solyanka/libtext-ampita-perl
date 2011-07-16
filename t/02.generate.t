use strict;
use warnings;
use Test::Base tests => 6;

BEGIN { use_ok('Text::Ampita') };

can_ok('Text::Ampita', 'generate');

my $src = Text::Ampita->generate(q{}, {});

ok(! ref $src, 'output scalar');

my $code = eval { eval $src };

ok(! $@, 'enable to eval');
is('CODE', ref $code, 'generate code source');
is(q{}, $code->(), 'return empty string');

