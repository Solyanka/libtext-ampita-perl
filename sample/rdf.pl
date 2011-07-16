#!/usr/bin/env perl
use strict;
use warnings;
use Text::Ampita;

my $source = <<'RDF';
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description id="trackback"
  rdf:about="URI"
  trackback:ping="URI"
  dc:title="TEXT"
  dc:identifier="URI"
  dc:description="TEXT" />

<rdf:Description id="entry" rdf:about="URI">
 <dc:title>TEXT</dc:title>
</rdf:Description>
</rdf:RDF>
RDF

my $binding = (sub{
    my($resource, $title);
    return {
        '#trackback' => sub{
            shift->({
                'rdf:about' => 'http://example.jp/blog/',
                'dc:title' => 'hoge hoge',
                'dc:description' => 'hoge&nbsp;hoge',
                'trackback:ping' => 'http://example.jp/blog/ping?id=foo',
                'dc:identifier' => 'http://example.jp/blog/foo',
                'dc:data' => '2006-07-22T14:05:23+09:00',
            });
        },
        '#entry' => sub{
            for (
                ['hoge.html' => 'Hoge'],
                ['http://example.jp/blog/foo' => 'example &nbsp; hoge'],
            ) {
                ($resource, $title) = @{$_};
                $_[0]->({'rdf:about' => $resource});
            }
        },
        '#entry dc:title' => sub {
            shift->($title);
        },
    };
}->());

my $template = eval Text::Ampita->generate($source, $binding);
print $template->($binding);

__END__
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
  rdf:about="http://example.jp/blog/"
  trackback:ping="http://example.jp/blog/ping?id=foo"
  dc:title="hoge hoge"
  dc:identifier="http://example.jp/blog/foo"
  dc:description="hoge&nbsp;hoge"
  dc:data="2006-07-22T14:05:23+09:00" />

<rdf:Description rdf:about="hoge.html">
 <dc:title>hoge</dc:title>
</rdf:Description>
<rdf:Description rdf:about="http://example.jp/blog/foo">
 <dc:title>example &nbsp; hoge</dc:title>
</rdf:Description>
</rdf:RDF>

