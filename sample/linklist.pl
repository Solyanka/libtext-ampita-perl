#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<div class="linklist">
<span id="curno"></span>/<span id="totals"></span> :
<a id="prevfirst" href="index.html">front</a>
<a id="prevlink" href="">prev</a>
|
<a id="indexlink" href="index.html">front</a>
<span id="indexhere" class="here">front</span>
<span id="pagelinks">
<a href=""></a><span class="here"></span><span class="comma">,</span> 
</span>
|
<a id="nextlink" href="">next</a>
<a id="nextlast" href="index.html">front</a>
</div>

HTML

my $links = [map { sprintf "r%02d.html", $_ } 0 .. 35];
my $template = eval Text::Ampita->generate($source, LinkList->new(0, $links));

print $template->(LinkList->new(0, $links));
print $template->(LinkList->new(2, $links));
print $template->(LinkList->new(10, $links));
print $template->(LinkList->new(35, $links));

sub LinkList::new {
    my($class, $cur, $links, $list_width) = @_;
    $list_width ||= 7;
    my $length = @$links;
    my $w = $list_width > $length ? $length : $list_width;
    my $lefts = int(($w + 1) / 2) - 1;
    my $rights = $w - $lefts;
    my $listhead = $cur <= $lefts ? 0
        : $cur >= $length - $rights ? $length - $w
        : $cur - $lefts;
    my $listtail = $listhead + $w - 1;
    my $item;
    return {
        '#curno' => sub{ shift->($cur + 1) },
        '#totals' => sub{ shift->(scalar @$links) },
        '#prevfirst' => sub{
            if ($cur <= 0) {
                $_[0]->();
            }
        },
        '#prevlink' => sub{
            if ($cur > 0) {
                $_[0]->({href => $links->[$cur - 1]});
            }
        },
        '#nextlink' => sub{
            if ($cur < $length - 1) {
                $_[0]->({href => $links->[$cur + 1]});
            }
        },
        '#nextlast' => sub{
            if ($cur >= $length - 1) {
                $_[0]->();
            }
        },
        '#indexlink' => sub{ shift->() },
        '#indexhere' => sub{},
        '#pagelinks' => sub{
            for my $i ($listhead .. $listtail) {
                $item = $i;
                $_[0]->();
            }
        },
        '#pagelinks a' => sub{
            if ($item != $cur) {
                $_[0]->({href => $links->[$item]}, $item + 1);
            }
        },
        '#pagelinks .here' => sub{
            if ($item == $cur) {
                $_[0]->($item + 1);
            }
        },
        '#pagelinks .comma' => sub{
            if ($item != $listtail) {
                $_[0]->({class => undef});
            }
        }
    };
}

__END__
<div class="linklist">
1/36 :
<a href="index.html">front</a>
|
<a href="index.html">front</a>
<span class="here">1</span>,
<a href="r01.html">2</a>,
<a href="r02.html">3</a>,
<a href="r03.html">4</a>,
<a href="r04.html">5</a>,
<a href="r05.html">6</a>,
<a href="r06.html">7</a>
|
<a href="r01.html">next</a>
</div>

<div class="linklist">
3/36 :
<a href="r01.html">prev</a>
|
<a href="index.html">front</a>
<a href="r00.html">1</a>,
<a href="r01.html">2</a>,
<span class="here">3</span>,
<a href="r03.html">4</a>,
<a href="r04.html">5</a>,
<a href="r05.html">6</a>,
<a href="r06.html">7</a>
|
<a href="r03.html">next</a>
</div>

<div class="linklist">
11/36 :
<a href="r09.html">prev</a>
|
<a href="index.html">front</a>
<a href="r07.html">8</a>,
<a href="r08.html">9</a>,
<a href="r09.html">10</a>,
<span class="here">11</span>,
<a href="r11.html">12</a>,
<a href="r12.html">13</a>,
<a href="r13.html">14</a>
|
<a href="r11.html">next</a>
</div>

<div class="linklist">
36/36 :
<a href="r34.html">prev</a>
|
<a href="index.html">front</a>
<a href="r29.html">30</a>,
<a href="r30.html">31</a>,
<a href="r31.html">32</a>,
<a href="r32.html">33</a>,
<a href="r33.html">34</a>,
<a href="r34.html">35</a>,
<span class="here">36</span>
|
<a href="index.html">front</a>
</div>

