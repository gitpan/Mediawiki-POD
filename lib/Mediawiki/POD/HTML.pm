
# a subclass of Pod::Simple to catch X<keyword> and =head lines

package Mediawiki::POD::HTML;

use base qw/Pod::Simple::HTML/;

$VERSION = '0.01';

use strict;

my $in_headline = 0;
my $in_x = 0;

sub _handle_element_start
  {
  my($parser, $element_name, $attr) = @_;

  if ($element_name =~ /^head/)
    {
    $parser->{_html_headlines} = [] unless defined $parser->{_html_headlines};
    push @{ $parser->{_html_headlines} }, $element_name . ' ';
    $in_headline = 1;
    }
  $parser->SUPER::_handle_element_start($element_name, $attr);
  }

sub _handle_element_end
  {
  my($parser, $element_name) = @_;

  if ($element_name =~ /^head/)
    {
    $in_headline = 0;
    }
  $parser->SUPER::_handle_element_end($element_name);
  }

sub _handle_text {
  my($parser, $text) = @_;

  if ($in_headline != 0)
    {
    $parser->{_html_headlines}->[-1] .= $text;
    }
  $parser->SUPER::_handle_text($text);
  }

sub get_headlines
  {
  my $parser = shift;

  $parser->{_html_headlines};
  }

1;

__END__

=pod

=head1 NAME

Mediawiki::POD::HTML - a subclass to catch X<> and =head lines

=head1 SYNOPSIS

	use Mediawiki::POD::HTML;
	
	my $parser = Mediawiki::POD::HTML->new();

	my $html = $parser->parse_string_document($POD);

=head1 DESCRIPTION

Turns a given POD (Plain Old Documentation) into HTML code.

This subclass of L<Pod::Simple::HTML> catches C<=head> directives,
and then allows you to assemble a TOC (table of contents) from
the captured headlines.

=head1 METHODS

=head2 get_headlines()

Return all the captured headlines as an ARRAY ref.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms of the GPL.

See the LICENSE file for information.

=head1 AUTHOR

(c) by Tels bloodgate.com 2007

=head1 SEE ALSO

L<http://bloodgate.com/wiki/>.

=cut
