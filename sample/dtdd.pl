#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

# tricky markup of definition lists to pass the W3C validator.
# <!ELEMENT dl (dt|dd)+>
my $source = <<'XHTML';
<dl>
<dd id="ditem">
<dl>
 <dt></dt>
 <dd></dd>
</dl>
</dd>
</dl>
XHTML
my $binding = sub{
    my @symbol = qw(dollar scalar atmark array percent hash);
    my($t, $d);
    return {
        '#ditem' => sub{ shift->({-skip => 'tag'}) },
        '#ditem dl' => sub{
            my($yield) = @_;
            while (($t, $d) = splice @symbol, 0, 2) {
                $yield->({-skip => 'tag'});
            }
        },
        '#ditem dt' => sub{ shift->($t) },
        '#ditem dd' => sub{ shift->($d) },
    };
}->();
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<dl>
 <dt>dollar</dt>
 <dd>scalar</dd>
 <dt>atmark</dt>
 <dd>array</dd>
 <dt>percent</dt>
 <dd>hash</dd>
</dl>

