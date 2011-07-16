use strict;
use warnings;
use Test::Base;
use Text::Ampita;

plan tests => 1 * blocks;

filters {
    input => [qw(eval test_generate)],
    expected => [qw(chomp)],
};

run_is_deeply 'input' => 'expected';

sub test_generate {
    my($xml, $binding) = @_;
    my $perl_script = Text::Ampita->generate($xml, $binding);
    my $perl_code = eval $perl_script;
    return $perl_code->($binding);
}

__END__

=== <?xml..?><!DOCTYPE>
--- input
'<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja" dir="ltr">
</html>',
{}
--- expected
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja" dir="ltr">
</html>

=== yield->({PROP}, TEXT)
--- input
'<a id="hoge" href="">org.</a>',
{
    '#hoge' => sub{
        my($yield) = @_;
        $yield->({href => '/hoge.html', title => 'test'}, 'inner');
    },
}
--- expected
<a href="/hoge.html" title="test">inner</a>

=== yield->(TEXT)
--- input
'<b id="hoge">org.</b>',
{
    '#hoge' => sub{ shift->('inner') },
}
--- expected
<b>inner</b>

=== yield->({PROP})
--- input
'<a id="hoge" href="">org.</a>',
{
    '#hoge' => sub{
        my($yield) = @_;
        $yield->({href => '/hoge.html', title => 'test'});
    },
}
--- expected
<a href="/hoge.html" title="test">org.</a>

=== yield->()
--- input
'<a id="hoge" href="/hoge.html">org.</a>',
{
    '#hoge' => sub{
        my($yield) = @_;
        $yield->();
    },
}
--- expected
<a href="/hoge.html">org.</a>

=== hoge-inner
--- input
'<b id="hoge">org.</b>',
{
    '#hoge' => sub{ shift->({id => 'hoge'}, 'inner') },
}
--- expected
<b id="hoge">inner</b>

=== inner text_filter
--- input
'<b id="hoge">org.</b>',
{
    '#hoge' => sub{ shift->('<&>"&nbsp;') },
}
--- expected
<b>&lt;&amp;&gt;&quot;&nbsp;</b>

=== inner xml_filter
--- input
'<textarea id="hoge">org.</textarea>',
{
    '#hoge' => sub{ shift->('<&>"&nbsp;') },
}
--- expected
<textarea>&lt;&amp;&gt;&quot;&amp;nbsp;</textarea>

=== inner modifier
--- input
'<a>XML</a>
<b>HTML</b>
<c>RAW</c>
<d>TEXT</d>
<e>default</e>',
{
    'a' => sub{ shift->('<&>"&amp;&nbsp;') },
    'b' => sub{ shift->('<&>"&amp;&nbsp;') },
    'c' => sub{ shift->('<&>"&amp;&nbsp;') },
    'd' => sub{ shift->('<&>"&amp;&nbsp;') },
    'e' => sub{ shift->('<&>"&amp;&nbsp;') },
}
--- expected
<a>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;</a>
<b>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;</b>
<c><&>"&amp;&nbsp;</c>
<d>&lt;&amp;&gt;&quot;&amp;&nbsp;</d>
<e>&lt;&amp;&gt;&quot;&amp;&nbsp;</e>

=== tagname tagname
--- input
'<p><code><span></span></code></p>
<div><code><span></span></code></div>',
{
    'p span' => sub{ shift->('paragraph') },
    'div span' => sub{ shift->('division') },
}
--- expected
<p><code>paragraph</code></p>
<div><code>division</code></div>

=== id tagname
--- input
'<p id="foo"><span></span></p>
<p id="bar"><span></span></p>',
{
    '#foo span' => sub{ shift->('FOO') },
    '#bar span' => sub{ shift->('BAR') },
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== tagnameid tagname
--- input
'<p id="foo"><span></span></p>
<p id="bar"><span></span></p>',
{
    'p#foo span' => sub{ shift->('FOO') },
    'p#bar span' => sub{ shift->('BAR') },
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== tagname[id=""] tagname
--- input
'<p id="foo"><span></span></p>
<p id="bar"><span></span></p>',
{
    'p[id="foo"] span' => sub{ shift->('FOO') },
    'p[id="bar"] span' => sub{ shift->('BAR') },
}
--- expected
<p id="foo">FOO</p>
<p id="bar">BAR</p>

=== .class tagname
--- input
'<p class="foo"><span></span></p>
<p class="bar"><span></span></p>',
{
    '.foo span' => sub{ shift->('FOO') },
    '.bar span' => sub{ shift->('BAR') },
}
--- expected
<p class="foo">FOO</p>
<p class="bar">BAR</p>

=== tagname.class tagname
--- input
'<p class="foo"><span></span></p>
<p class="bar"><span></span></p>',
{
    'p.foo span' => sub{ shift->('FOO') },
    'p.bar span' => sub{ shift->('BAR') },
}
--- expected
<p class="foo">FOO</p>
<p class="bar">BAR</p>

=== skip tag
--- input
'<b id="hoge">org.</b>',
{
    '#hoge' => sub{ shift->({-skip => 'tag'}, 'outer') },
}
--- expected
outer

=== skip tag text_filter
--- input
'<b id="hoge">foo</b>',
{
    '#hoge' => sub{ shift->({-skip => 'tag'}, '<&>"&nbsp;') },
}
--- expected
&lt;&amp;&gt;&quot;&nbsp;

=== skip tag RAW
--- input
'<b id="hoge">RAW</b>',
{
    '#hoge' => sub{ shift->({-skip => 'tag'}, '<![CDATA[<&>"&nbsp;]]>') },
}
--- expected
<![CDATA[<&>"&nbsp;]]>

=== auto skip span
--- input
'<span><b><span id="foo">&nbsp;</span></b></span>',
{
    '#foo' => sub{ shift->('test') },
}
--- expected
<span><b>test</b></span>

=== doesnt auto skip span
--- input
'<span><b><span class="foo">&nbsp;</span></b></span>',
{
    '.foo' => sub{ shift->('test') },
}
--- expected
<span><b><span class="foo">test</span></b></span>

=== empty inner
--- input
'<link id="hoge" />',
{
    'link' => sub{ shift->('FOO') },
}
--- expected
<link />

=== empty inner-id
--- input
'<link id="hoge" />',
{
    'link' => sub{ shift->({id => 'hoge'}, 'FOO') },
}
--- expected
<link id="hoge" />

=== empty skip tag
--- input
'<link id="hoge" />FOO',
{
    'link' => sub{ shift->({-skip => 'tag'}, 'BAR') },
}
--- expected
FOO

=== attribute default filter
--- input
'<link href=""
 src=""
 cite=""
 title=""
 rdf:resource=""/>',
{
    'link' => sub{
        shift->({
            'href' => '&<>"&amp;%12%45%+',
            'src' => '&<>"&amp;%12%45%+',
            'cite' => '&<>"&amp;%12%45%+',
            'title' => '&<>"&amp;%12%45%+',
            'rdf:resource' => '&<>"&amp;%12%45%+'
        });
    },
}
--- expected
<link href="&amp;%3C%3E%22&amp;%12%45%25+"
 src="&amp;%3C%3E%22&amp;%12%45%25+"
 cite="&amp;%3C%3E%22&amp;%12%45%25+"
 title="&amp;&lt;&gt;&quot;&amp;%12%45%+"
 rdf:resource="&amp;%3C%3E%22&amp;%12%45%25+"/>

=== attribute modifier
--- input
'<link a="URI"
 b="URL"
 c="XML"
 d="HTML"
 e="RAW"
 f="TEXT"/>',
{
    'link' => sub{
        shift->({
            'a' => '&<>"&amp;%12%45%+',
            'b' => '&<>"&amp;%12%45%+',
            'c' => '&<>"&amp;%12%45%+',
            'd' => '&<>"&amp;%12%45%+',
            'e' => '&<>&amp;%12%45%+',
            'f' => '&<>"&amp;%12%45%+',
        });
    },
}
--- expected
<link a="&amp;%3C%3E%22&amp;%12%45%25+"
 b="&amp;%3C%3E%22&amp;%12%45%25+"
 c="&amp;&lt;&gt;&quot;&amp;amp;%12%45%+"
 d="&amp;&lt;&gt;&quot;&amp;amp;%12%45%+"
 e="&<>&amp;%12%45%+"
 f="&amp;&lt;&gt;&quot;&amp;%12%45%+"/>

=== add attribute
--- input
'<b id="hoge" title="fuga">org.</b>',
{
    '#hoge' => sub{ shift->({class => 'bold'}) },
}
--- expected
<b title="fuga" class="bold">org.</b>

=== delete attribute
--- input
'<b id="hoge" title="fuga">org.</b>',
{
    '#hoge' => sub{ shift->({title => undef}) },
}
--- expected
<b>org.</b>

=== replace attribute
--- input
'<a id="hoge" href="foo">org.</a>',
{
    '#hoge' => sub{ shift->({href => 'bar'}) },
}
--- expected
<a href="bar">org.</a>

=== do not yield
--- input
'<b>foo<a id="hoge" href="foo">org.</a></b>',
{
    '#hoge' => sub{ },
}
--- expected
<b>foo</b>

=== skip all
--- input
'<b>foo<a id="hoge" href="foo">org.</a></b>',
{
    '#hoge' => sub{ shift->({-skip => 'all'}) },
}
--- expected
<b>foo</b>

=== <style>CDATA</style>
--- input
'<style type="text/css"><![CDATA[
 .c > .d {color:red}
]]></style>',
{
    'style' => sub{ shift->() },
}
--- expected
<style type="text/css"><![CDATA[
 .c > .d {color:red}
]]></style>

=== <script>CDATA</script>
--- input
'<script>//<![CDATA[
if (hoge<fuga) { fuga(); }
]]></script>',
{
    'script' => sub{ shift->({type => 'text/javascript'}) },
}
--- expected
<script type="text/javascript">//<![CDATA[
if (hoge<fuga) { fuga(); }
]]></script>

=== leave id
--- input
'<h1></h1>
<p id="asis"><a id="foo" href=""></a></p>',
{
    'h1' => sub{ shift->('Hello, World') },
    '#foo' => sub{ shift->({href => 'http://www.w3.org'}, 'W3C') },
}
--- expected
<h1>Hello, World</h1>
<p id="asis"><a href="http://www.w3.org">W3C</a></p>

=== repeated yield->()
--- input
'<ul>
 <li></li>
</ul>',
{
    'li' => sub{
        my($yield) = @_;
        for ('A' .. 'C') {
            $yield->($_ eq 'B' ? {class => 'here'} : {}, $_);
        }
    },
}
--- expected
<ul>
 <li>A</li>
 <li class="here">B</li>
 <li>C</li>
</ul>

=== RDF
--- input
'<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:wot="http://xmlns.com/wot/0.1/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="ja">
<foaf:Person rdf:ID="tociyuki">
 <foaf:mbox_sha1sum id="sha1"></foaf:mbox_sha1sum>
 <foaf:name>MIZUTANI, Tociyuki</foaf:name>
 <foaf:weblog id="blog" dc:title="" />
</foaf:Person>
</rdf:RDF>',
{
    '#sha1' => sub{ shift->('46f39be840c113a8d654aff099814f49bb5639b6') },
    '#blog' => sub{
        shift->({
            'rdf:resource' => "http://d.hatena.ne.jp/tociyuki",
            'dc:title' => "Tociyuki::Diary",
        });
    },
}
--- expected
<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:wot="http://xmlns.com/wot/0.1/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="ja">
<foaf:Person rdf:ID="tociyuki">
 <foaf:mbox_sha1sum>46f39be840c113a8d654aff099814f49bb5639b6</foaf:mbox_sha1sum>
 <foaf:name>MIZUTANI, Tociyuki</foaf:name>
 <foaf:weblog dc:title="Tociyuki::Diary" rdf:resource="http://d.hatena.ne.jp/tociyuki" />
</foaf:Person>
</rdf:RDF>

