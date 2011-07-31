#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<demo:setvar name="hoge" value="HOGE"/>
<div>
 <var></var> = <em><demo:getvar name="hoge"></demo:getvar></em>
</div>
<demo:setarray name="location">
  <demo:li>Jan Mayen</demo:li>
  <demo:li>Bodo</demo:li>
  <demo:li>Trondheim</demo:li>
  <demo:li>Bergen</demo:li>
</demo:setarray>
<ol>
 <li></li>
</ol>
HTML
my $binding = DemoVar->new;
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

sub DemoVar::new {
    my %var;
    my $array_name;
    return {
        'demo:setvar' => sub{
            my($yield, $attr) = @_;
            my $name = $attr->{'name'};
            my $value = $attr->{'value'};
            $var{$name} = $value;
        },
        'var' => sub{ shift->('hoge') },
        'demo:getvar' => sub{
            my($yield, $attr) = @_;
            my $name = $attr->{'name'};
            $yield->({-skip => 'tag'}, $var{$name} || q{});
        },
        'demo:setarray' => sub{
            my($yield, $attr) = @_;
            $array_name = $attr->{'name'};
            $var{$array_name} = [];
            $yield->({-skip => 'tag'});
        },
        'demo:li' => sub{
            my($yield, $attr, $data) = @_;
            push @{$var{$array_name}}, $data;
        },
        'li' => sub{
            my($yield) = @_;
            for (@{$var{location}}) {
                $yield->($_);
            }
        },
    };
}

__END__
<div>
 <var>hoge</var> = <em>HOGE</em>
</div>
<ol>
 <li>Jan Mayen</li>
 <li>Bodo</li>
 <li>Trondheim</li>
 <li>Bergen</li>
</ol>

