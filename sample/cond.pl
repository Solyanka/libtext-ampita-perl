#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<html>
 <body>
  <h1>conditional</h1>
  <div id="cond">
  <h2 id="title"></h2>
  <p id="zero">no data.</p>
  <p id="one">one: <span>data</span>.</p>
  <ul id="many">
   <li></li>
  </ul>
  </div>
 </body>
</html>
HTML
my $binding = Cond->new;
my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

sub Cond::new {
    my $cond;
    my $many_list_item;
    return {
        '#cond' => sub{
            my($yield) = @_;
            for my $c (
                {title => 'three', many => [qw(1 2 3)]},
                {title => 'zero', zero => 0},
                {title => 'one', one => 1},
            ) {
                $cond = $c;
                $yield->({-skip => 'tag'});
            }
        },
        '#title' => sub{
            my($yield) = @_;
            $yield->($cond->{title});
        },
        '#zero' => sub{
            my($yield) = @_;
            if (exists $cond->{zero}) {
                $yield->();
            }
        },
        '#one' => sub{
            my($yield) = @_;
            if (exists $cond->{one}) {
                $yield->();
            }
        },
        '#one span' => sub{
            my($yield) = @_;
            $yield->($cond->{one});
        },
        '#many' => sub{
            my($yield) = @_;
            if (exists $cond->{many}) {
                $yield->();
            }
        },
        '#many li' => sub{
            my($yield) = @_;
            for (@{$cond->{many}}) {
                $yield->($_);
            }
        },
    };
}

__END__
<html>
 <body>
  <h1>conditional</h1>
  <h2>three</h2>
  <ul>
   <li>1</li>
   <li>2</li>
   <li>3</li>
  </ul>
  <h2>zero</h2>
  <p>no data.</p>
  <h2>one</h2>
  <p>one: 1.</p>
 </body>
</html>
