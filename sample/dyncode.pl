#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<h1></h1>
<ul>
 <li id="langs"><a href=""></a></li>
</ul>
HTML
my $binding = sub{
    my(@langs) = @_;
    my $entry;
    return {
        'h1' => sub{
            shift->({id => 'lightlangs'}, 'Example of Lightweight languages');
        },
        'li#langs' => sub{
            my($yield) = @_;
            my @a = @langs;
            while (@{$entry}{'name', 'link'} = splice @a, 0, 2) {
                $yield->();
            }            
        },
        'li#langs a' => sub{
            shift->({href => $entry->{'link'}}, $entry->{'name'});
        }
    };
}->(
    'Python' => 'http://www.python.org/',
    'Ruby' => 'http://www.ruby-lang.org/',
    'Perl' => 'http://www.perl.org/',
);
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<h1 id="lightlangs">Example of Lightweight languages</h1>
<ul>
 <li><a href="http://www.python.org/">Python</a></li>
 <li><a href="http://www.ruby-lang.org/">Ruby</a></li>
 <li><a href="http://www.perl.org/">Perl</a></li>
</ul>

