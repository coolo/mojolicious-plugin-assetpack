use t::Helper;
my $t;

$ENV{MOJO_MODE} = 'development';
$t = t::Helper->t(pipes => ['Css']);
$t->app->asset->process;
$t->get_ok('/')->status_is(200);
$t->get_ok($t->tx->res->dom->at('link')->{href})->status_is(200)
  ->content_like(qr{\.development});

$t = t::Helper->t(pipes => ['Css']);
$t->app->asset->process('foo.def');
$t->get_ok('/')->status_is(200);
$t->get_ok($t->tx->res->dom->at('link')->{href})->status_is(200)->content_like(qr{\.foo});

$ENV{MOJO_MODE} = 'production';
$t = t::Helper->t(pipes => ['Css']);
$t->app->asset->process;
$t->get_ok('/')->status_is(200);
$t->get_ok($t->tx->res->dom->at('link')->{href})->status_is(200)
  ->content_like(qr{\.production});

done_testing;

__DATA__
@@ index.html.ep
%= asset 'app.css'
@@ assetpack.production.def
! app.css
< dev.css
@@ assetpack.development.def
! app.css
< dev.css
@@ foo.development.def
! app.css
< foo.css
@@ dev.css
.development { color: #f00; }
@@ foo.css
.foo { color: #0f0; }
@@ prod.css
.production { color: #00f; }
