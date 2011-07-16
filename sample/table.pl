#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<table>
 <caption></caption>
 <tr>
  <td></td>
 </tr>
</table>
HTML
my $binding = (sub{
    my $row;
    my @rows = (
        [{width => '32', align => 'left'}, 'L1', 'L2'],
        [{align => 'center', colspan => 2}, 'C1'],
        [{align => 'right'}, 'R1', 'R2'],
    );
    return {
        'caption' => sub{ shift->('ABC') },
        'tr' => sub{
            my($yield) = @_;
            for my $x (@rows) {
                $row = $x;
                $yield->();
            }
        },
        'td' => sub{
            my($yield) = @_;
            my($prop, @col) = @{$row};
            for my $c (@col) {
                $yield->($prop, $c);
            }
        },
    };
}->());
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<table>
 <caption align="left">ABC</caption>
 <tr>
  <td width="32" align="left">L1</td>
  <td width="32" align="left">L2</td>
 </tr>
 <tr>
  <td align="center" colspan="2">C1</td>
 </tr>
 <tr>
  <td align="right">R1</td>
  <td align="right">R2</td>
 </tr>
</table>

