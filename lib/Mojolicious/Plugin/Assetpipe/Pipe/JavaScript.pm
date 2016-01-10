package Mojolicious::Plugin::Assetpipe::Pipe::JavaScript;
use Mojo::Base 'Mojolicious::Plugin::Assetpipe::Pipe';
use Mojolicious::Plugin::Assetpipe::Util qw(diag load_module DEBUG);

sub _process {
  my ($self, $assets) = @_;
  my $l;

  return unless $self->assetpipe->minify;
  return $assets->each(
    sub {
      my ($asset, $index) = @_;
      return if $asset->format ne 'js' or $asset->minified;
      load_module 'JavaScript::Minifier::XS'
        or die qq(Could not to load "JavaScript::Minifier::XS": $@)
        unless $l++;

      diag 'Minify "%s" with checksum "%s".', $asset->url, $asset->checksum if DEBUG;
      $asset->checksum;    # make sure checksum() is calculated before changing content()
      $asset->content(JavaScript::Minifier::XS::minify($asset->content))->minified(1);
    }
  );
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Assetpipe::Pipe::JavaScript - Minify JavaScript

=head1 DESCRIPTION

L<Mojolicious::Plugin::Assetpipe::Pipe::JavaScript> will minify your "js"
assets if L<Mojolicious::Plugin::Assetpipe/minify> is true and the asset is
not already minified.

=head1 SEE ALSO

L<Mojolicious::Plugin::Assetpipe>.

=cut
