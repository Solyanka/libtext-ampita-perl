#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'HTML';
<html>
 <body>
  <h1><a id="a1" href="replaced">replacing attributes</a></h1>
  <p><a id="a2" href="http://example.net/">examples</a></p>
  <p><a id="a3" href="http://d.hatena.ne.jp/$1/$2">id:$1:$2</a></p>
 </body>
</html>
HTML

my $binding = {
    '#a1' => sub{
        shift->({href => 'http://hoge.gr.jp/'});
    },
    '#a2' => sub{
        my($yield, $attr, $data) = @_;
        $yield->(
            {href => $attr->{'href'} . 'ja/'},
            $data . ' (Japanese)',
        );
    },
    '#a3' => sub{
        my($yield, $attr, $data) = @_;
        my @path = ('someone', 132424);
        $yield->(
            {href => expand($attr->{'href'}, @path)},
            expand($data, @path),
        );
    },
};

sub expand {
    my($text, @arg) = @_;
    $text =~ s{\$([1-9]\d?)}{ defined $arg[$1 - 1] ? $arg[$1 - 1] : q{} }msxge;
    return $text;
}

my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<html>
 <body>
  <h1><a href="http://hoge.gr.jp/">replacing attributes</a></h1>
  <p><a href="http://example.net/ja/">examples (Japanese)</a></p>
  <p><a href="http://d.hatena.ne.jp/someone/132424">id:someone:132424</a></p>
 </body>
</html>
