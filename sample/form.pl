#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<html>
 <body>
  <form id="form1">
   <select name="f0">
    <option></option>
   </select>
   <input type="text" name="f1" />
   <textarea name="f2"></textarea>
   <select name="f3">
    <option value="f3a">F3A</option>
    <option value="f3b">F3B</option>
    <option value="f3c">F3C</option>
   </select>
   <div id="f4g">
   <input type="checkbox" name="f4" /><span id="f4v">&nbsp;</span>,
   </div>
   <input type="radio" name="f5" value="a" />A,
   <input type="radio" name="f5" value="b" />B,
   <input type="radio" name="f5" value="c" />C,
  </form>
 </body>
</html>
HTML
my $binding = (sub{
    my($value, $label);
    return {
        '#form1' => sub{
            shift->({method => 'post', action => 'hoge'});
        },
        'select[name="f0"] option' => sub{
            my($yield) = @_;
            my $sel = 'f0c';
            for my $v (qw(f0a f0b f0c f0d)) {
                my @sel = $sel eq $v ? (selected => 'selected') : ();
                $yield->({value => $v, @sel}, uc $v);
            }
        },
        'input[name="f1"]' => sub{ shift->({value => 'hoge <&nbsp;">'}) },
        'textarea[name="f2"]' => sub{ shift->('fuga <&nbsp;">') },
        'select[name="f3"] option[value="f3b"]' => sub{
            shift->({selected => 'selected'});
        },
        '#f4g' => sub{
            my($yield) = @_;
            for my $v (qw(foo bar baz)) {
                ($value, $label) = ($v, uc $v);
                $yield->({-skip => 'tag'});
            }
        },
        'input[name="f4"]' => sub{
            shift->({value => $value});
        },
        '#f4v' => sub{
            shift->($label);
        },
        'input[name="f5"]' => sub{
            my($yield, $attr) = @_;
            $yield->(
                $attr->{'value'} eq 'a' ? {checked => 'checked'} : {}
            );
        },
    }
}->());
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<html>
 <body>
  <form action="hoge" method="post">
   <select name="f0">
    <option value="f0a">F0A</option>
    <option value="f0b">F0B</option>
    <option value="f0c" selected="selected">F0C</option>
    <option value="f0d">F0D</option>
   </select>
   <input type="text" name="f1" value="hoge &lt;&amp;nbsp;&quot;&gt;" />
   <textarea name="f2">fuga &lt;&amp;nbsp;&quot;&gt;</textarea>
   <select name="f3">
    <option value="f3a">F3A</option>
    <option value="f3b" selected="selected">F3B</option>
    <option value="f3c">F3C</option>
   </select>
   <input type="checkbox" name="f4" value="foo" />FOO,
   <input type="checkbox" name="f4" value="bar" />BAR,
   <input type="checkbox" name="f4" value="baz" />BAZ,
   <input type="radio" name="f5" value="a" checked="checked" />A,
   <input type="radio" name="f5" value="b" />B,
   <input type="radio" name="f5" value="c" />C,
  </form>
 </body>
</html>

