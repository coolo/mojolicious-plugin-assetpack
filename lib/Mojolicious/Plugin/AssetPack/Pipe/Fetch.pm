package Mojolicious::Plugin::AssetPack::Pipe::Fetch;
use Mojo::Base 'Mojolicious::Plugin::AssetPack::Pipe';
use Mojolicious::Plugin::AssetPack::Util qw(diag DEBUG);
use Mojo::URL;

# Only made public for quick fixes. Subject for change
our $URL_RE = qr{url\((['"])(.*?)\1\)};

sub process {
  my ($self, $assets) = @_;
  my $store = $self->assetpack->store;
  my $route = $self->assetpack->route;

  return $assets->each(
    sub {
      my ($asset, $index) = @_;
      return unless $asset->format eq 'css';
      return unless $asset->url =~ /^https?:/;

      my $base    = Mojo::URL->new($asset->url);
      my $content = $asset->content;
      my %seen;

      while ($content =~ /$URL_RE/g) {
        my $url   = Mojo::URL->new($2);
        my $len   = length $2;
        my $start = pos($content) - length($1) - $len - 1;
        $url = $url->base($base)->to_abs unless $url->is_abs;
        next if $seen{$url}++;
        diag "Fetch resource $url" if DEBUG;
        my $related = $store->asset($url);
        $self->assetpack->process($related->name, $related);
        my $path = $route->render($related->TO_JSON);
        $path =~ s!^/!!;
        my $up = join '', map {'../'} $path =~ m!\/!g;
        substr $content, $start, $len,
          Mojo::URL->new("$up$path")->query(Mojo::Parameters->new);
        pos($content) = $start + $len;
      }

      $asset->content($content);
    }
  );
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AssetPack::Pipe::Fetch - Fetch related assets

=head1 SYNOPSIS

  use Mojolicious::Lite;
  plugin AssetPack => {pipes => [qw(Css Fetch)]};
  app->asset->process(
    "app.css" =>
      "https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css"
  );

=head1 DESCRIPTION

L<Mojolicious::Plugin::AssetPack::Pipe::Fetch> will look for "url()" in a CSS
file and fetch the resource from the remote location.

Note that this pipe is EXPERIMENTAL and subject for change.

=head1 METHODS

=head2 process

See L<Mojolicious::Plugin::AssetPack::Pipe/process>.

=head1 SEE ALSO

L<Mojolicious::Plugin::AssetPack>.

=cut
