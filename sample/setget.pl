#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<span id="set_hoge">HOGE HOGE</span>
<ul>
 <li><span id="get_hoge"></span></li>
</ul>
HTML
my $binding = (sub {
    my @a = (3 .. 6);
    my $hoge;
    my $item;
    return {
        '#set_hoge' => sub {
            my($yield, $attr, $data) = @_;
            $hoge = $data;
        },
        '#get_hoge' => sub {
            shift->($hoge . q{ } . $item);
        },
        'li' => sub {
            for my $i (@a) {
                $item = $i;
                $_[0]->();
            }
        }
    };
}->());
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<ul>
 <li>HOGE HOGE 3</li>
 <li>HOGE HOGE 4</li>
 <li>HOGE HOGE 5</li>
 <li>HOGE HOGE 6</li>
</ul>
