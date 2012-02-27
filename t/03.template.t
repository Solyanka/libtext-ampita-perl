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
    'a' => sub{ shift->('<&>"&amp;&nbsp;\\') },
    'b' => sub{ shift->('<&>"&amp;&nbsp;\\') },
    'c' => sub{ shift->('<&>"&amp;&nbsp;\\') },
    'd' => sub{ shift->('<&>"&amp;&nbsp;\\') },
    'e' => sub{ shift->('<&>"&amp;&nbsp;\\') },
}
--- expected
<a>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;&#92;</a>
<b>&lt;&amp;&gt;&quot;&amp;amp;&amp;nbsp;&#92;</b>
<c><&>"&amp;&nbsp;\</c>
<d>&lt;&amp;&gt;&quot;&amp;&nbsp;&#92;</d>
<e>&lt;&amp;&gt;&quot;&amp;&nbsp;&#92;</e>

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

=== .class
--- input
'<p class="foo"></p>
<p class="bar foo"></p>',
{
    '.foo' => sub{ shift->('FOO') },
}
--- expected
<p class="foo">FOO</p>
<p class="bar foo">FOO</p>

=== [class~="foo"]
--- input
'<p class="foo"></p>
<p class="bar foo"></p>',
{
    '[class~="foo"]' => sub{ shift->('FOO') },
}
--- expected
<p class="foo">FOO</p>
<p class="bar foo">FOO</p>

=== [class="foo"]
--- input
'<p class="foo"></p>
<p class="bar foo">bar</p>',
{
    '[class="foo"]' => sub{ shift->('FOO') },
}
--- expected
<p class="foo">FOO</p>
<p class="bar foo">bar</p>

=== [class^="foo"]
--- input
'<p class="foo"></p>
<p class="foo bar"></p>
<p class="bar foo">bar</p>',
{
    '[class^="foo"]' => sub{ shift->('FOO') },
}
--- expected
<p class="foo">FOO</p>
<p class="foo bar">FOO</p>
<p class="bar foo">bar</p>

=== [class$="foo"]
--- input
'<p class="foo"></p>
<p class="foo bar">bar</p>
<p class="bar foo"></p>',
{
    '[class$="foo"]' => sub{ shift->('FOO') },
}
--- expected
<p class="foo">FOO</p>
<p class="foo bar">bar</p>
<p class="bar foo">FOO</p>

=== [class*="oo"]
--- input
'<p class="foo"></p>
<p class="bar">bar</p>
<p class="bar foo"></p>',
{
    '[class*="oo"]' => sub{ shift->('ok') },
}
--- expected
<p class="foo">ok</p>
<p class="bar">bar</p>
<p class="bar foo">ok</p>

=== [class|="entry"]
--- input
'<p class="entry">not ok</p>
<p class="entry-body">not ok</p>
<p class="hentry-body">not ok</p>',
{
    '[class|="entry"]' => sub{ shift->('ok') },
}
--- expected
<p class="entry">ok</p>
<p class="entry-body">ok</p>
<p class="hentry-body">not ok</p>

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
            'href' => '&<>"\\&amp;%12%45%+',
            'src' => '&<>"\\&amp;%12%45%+',
            'cite' => '&<>"\\&amp;%12%45%+',
            'title' => '&<>"\\&amp;%12%45%+',
            'rdf:resource' => '&<>"\\&amp;%12%45%+'
        });
    },
}
--- expected
<link href="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 src="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 cite="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 title="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"
 rdf:resource="&amp;%3C%3E%22%5C&amp;%12%45%25+"/>

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
            'a' => '&<>"\\&amp;%12%45%+',
            'b' => '&<>"\\&amp;%12%45%+',
            'c' => '&<>"\\&amp;%12%45%+',
            'd' => '&<>"\\&amp;%12%45%+',
            'e' => '&<>&amp;%12%45%+',
            'f' => '&<>"\\&amp;%12%45%+',
        });
    },
}
--- expected
<link a="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 b="&amp;%3C%3E%22%5C&amp;%12%45%25+"
 c="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+"
 d="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+"
 e="&<>&amp;%12%45%+"
 f="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"/>

=== attribute input default filter
--- input
'<input type="hidden"
    name=""
    value="" />',
{
    'input' => sub{
        shift->({
            'name' => '&<>"\\&amp;%12%45%+',
            'value' => '&<>"\\&amp;%12%45%+',
        });
    },
}
--- expected 
<input type="hidden"
    name="&amp;&lt;&gt;&quot;&#92;&amp;%12%45%+"
    value="&amp;&lt;&gt;&quot;&#92;&amp;amp;%12%45%+" />

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
            'rdf:resource' => "http://d.hatena.ne.jp/tociyuki/",
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
 <foaf:weblog dc:title="Tociyuki::Diary" rdf:resource="http://d.hatena.ne.jp/tociyuki/" />
</foaf:Person>
</rdf:RDF>

=== demo get attribute and data
--- input
'<html>
 <body>
  <h1><a id="mark:a1" href="replaced">replacing attributes</a></h1>
  <p><a id="mark:a2" href="http://example.net/">examples</a></p>
  <p><a id="mark:a3" href="http://d.hatena.ne.jp/$1/$2">id:$1:$2</a></p>
 </body>
</html>',
{
    '#mark:a1' => sub{
        shift->({href => 'http://hoge.gr.jp/'});
    },
    '#mark:a2' => sub{
        my($yield, $attr, $data) = @_;
        $yield->({href => $attr->{'href'} . 'ja/'}, $data . ' (Japanese)');
    },
    '#mark:a3' => sub{
        my($yield, $attr, $data) = @_;
        my @path = ('someone', 132424);
        my $href = $attr->{'href'};
        $href =~ s{[\$]([12])}{ $path[$1 - 1] }egmsx;
        $data =~ s{[\$]([12])}{ $path[$1 - 1] }egmsx;
        $yield->({href => $href}, $data);
    },
}
--- expected
<html>
 <body>
  <h1><a href="http://hoge.gr.jp/">replacing attributes</a></h1>
  <p><a href="http://example.net/ja/">examples (Japanese)</a></p>
  <p><a href="http://d.hatena.ne.jp/someone/132424">id:someone:132424</a></p>
 </body>
</html>

=== demo cond (ID-only mode)
--- input
'<html>
 <body>
  <h1>conditional</h1>
  <div id="mark:cond">
  <h2 id="mark:title"></h2>
  <p id="mark:zero">no data.</p>
  <p id="mark:one">one: <span id="mark:one-value">data</span>.</p>
  <ul id="mark:many">
   <li id="mark:many-each"></li>
  </ul>
  </div>
 </body>
</html>',
sub{
    my $cond;
    my $many_list_item;
    return {
        '#mark:cond' => sub{
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
        '#mark:title' => sub{
            my($yield) = @_;
            $yield->($cond->{title});
        },
        '#mark:zero' => sub{
            my($yield) = @_;
            if (exists $cond->{zero}) {
                $yield->();
            }
        },
        '#mark:one' => sub{
            my($yield) = @_;
            if (exists $cond->{one}) {
                $yield->();
            }
        },
        '#mark:one-value' => sub{
            my($yield) = @_;
            $yield->($cond->{one});
        },
        '#mark:many' => sub{
            my($yield) = @_;
            if (exists $cond->{many}) {
                $yield->();
            }
        },
        '#mark:many-each' => sub{
            my($yield) = @_;
            for (@{$cond->{many}}) {
                $yield->($_);
            }
        },
    };
}->()
--- expected
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

=== demo cond (CSS mode)
--- input
'<html>
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
</html>',
sub{
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
}->()
--- expected
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

=== demo form
--- input
'<html>
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
</html>',
sub{
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
}->()
--- expected
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

=== demo table (ID-only mode)
--- input
'<table>
 <caption id="mark:caption"></caption>
 <tr id="mark:tr">
  <td id="mark:td"></td>
 </tr>
</table>',
sub{
    my $row;
    my @rows = (
        [{width => '32', align => 'left'}, 'L1', 'L2'],
        [{align => 'center', colspan => 2}, 'C1'],
        [{align => 'right'}, 'R1', 'R2'],
    );
    return {
        '#mark:caption' => sub{ shift->('ABC') },
        '#mark:tr' => sub{
            my($yield) = @_;
            for my $x (@rows) {
                $row = $x;
                $yield->();
            }
        },
        '#mark:td' => sub{
            my($yield) = @_;
            my($prop, @col) = @{$row};
            for my $c (@col) {
                $yield->($prop, $c);
            }
        },
    };
}->()
--- expected
<table>
 <caption>ABC</caption>
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

=== demo table (CSS mode)
--- input
'<table>
 <caption></caption>
 <tr>
  <td></td>
 </tr>
</table>',
sub{
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
}->()
--- expected
<table>
 <caption>ABC</caption>
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

=== demo calendar
--- input
'<table class="calendar">
 <caption id="mark:caltitle"></caption>
 <tr><th id="mark:calweeklabel">mo tu we th fr st su</th></tr>
 <tr id="mark:calweek"><td id="mark:calday">&nbsp;</td></tr>
</table>',
sub{
    my($year, $month) = (2012, 3);
    my $wdoffset = 0;
    my @yday = (
        [-31, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
        [-31, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366],
    );
    my @msize = (
        [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        [31, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    );
    my $leap = ($year % 4 == 0
        && $year % 100 != 0 || $year % 400 == 0) ? 1 : 0;
    my $y = $year - 1;
    my $wmonth = ($y + (int $y / 4) - (int $y / 100) + (int $y / 400)
        + $yday[$leap][$month] + $wdoffset) % 7;
    my $msize = $msize[$leap][$month];
    my $week;
    return {
        '#mark:caltitle' => sub{
            shift->(sprintf "%04d-%02d", $year, $month);
        },
        '#mark:calweeklabel' => sub{
            my($yield, $attr, $data) = @_;
            my @wlabel = split /\s+/, $data;
            for (map { $wlabel[($_ - $wdoffset) % 7] } 0 .. 6) {
                $yield->($_);
            }
        },
        '#mark:calweek' => sub{
            my($yield) = @_;
            for (0 .. 5) {
                $week = $_;
                $yield->();
            }
        },
        '#mark:calday' => sub{
            my($yield) = @_;
            for my $wday (0 .. 6) {
                my $day = $week * 7 + $wday - $wmonth + 1;
                if ($day >= 1 && $day <= $msize) {
                    $yield->($day);
                }
                else {
                    $yield->();
                }
            }
        },
    };
}->()
--- expected
<table class="calendar">
 <caption>2012-03</caption>
 <tr><th>mo</th><th>tu</th><th>we</th><th>th</th><th>fr</th><th>st</th><th>su</th></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>1</td><td>2</td><td>3</td><td>4</td></tr>
 <tr><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td></tr>
 <tr><td>12</td><td>13</td><td>14</td><td>15</td><td>16</td><td>17</td><td>18</td></tr>
 <tr><td>19</td><td>20</td><td>21</td><td>22</td><td>23</td><td>24</td><td>25</td></tr>
 <tr><td>26</td><td>27</td><td>28</td><td>29</td><td>30</td><td>31</td><td>&nbsp;</td></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
</table>

