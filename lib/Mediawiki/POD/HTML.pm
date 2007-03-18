
# a subclass of Pod::Simple to catch X<keyword> and =head lines

package Mediawiki::POD::HTML;

use 5.008001;
use base qw/Pod::Simple::HTML/;
use Graph::Easy;
use Graph::Easy::Parser;

$VERSION = '0.03';

use strict;

sub new
  {
  my $class = shift;

  my $self = Pod::Simple::HTML->new(@_);

  $self->{_mediawiki_pod_html} = {};
  my $storage = $self->{_mediawiki_pod_html};

  # we do not need an index, we will generate it ourselves
  $self->index(0);

  $storage->{in_headline} = 0;
  $storage->{in_x} = 0;
  $storage->{in_graph} = 0;
  $storage->{headlines} = [];
  $storage->{graph_id} = 0;

  $storage->{search} = 'http://cpan.uwinnipeg.ca/search?query=##KEYWORD##';

  # we handle these, too:
  $self->accept_targets('graph', 'GRAPH');

  bless $self, $class;
  }

#############################################################################
# overriden methods for parsing:

sub _handle_element_start
  {
  my ($self, $element_name, $attr) = @_;

  #print STDERR "start '$element_name'\n";

  my $storage = $self->{_mediawiki_pod_html};

  if ($element_name eq 'X' && $storage->{in_x} == 0)
    {
    $storage->{in_x} = 1;
    $self->_my_output( '<div class="keywords">Keywords: &nbsp;' );
    }
  if ($element_name ne 'X' && $storage->{in_x} != 0)
    {
    # broken chain of X<> keywords
    $self->_my_output( '</div>' );
    $storage->{in_x} = 0;
    }

  if ($storage->{in_graph} && $element_name !~ /^Data/i)
    {
    my $parser = Graph::Easy::Parser->new();

    my $graph = $parser->from_text($storage->{cur_graph});
    
    $graph->set_attribute('gid', $storage->{graph_id}++);

    $self->_my_output( '<style type="text/css">' . $graph->css() . '</style>' );
    $self->_my_output( $graph->as_html() );

    $storage->{in_graph} = 0;
    $storage->{cur_graph} = '';
    }
  # other items
  if ($element_name eq 'for' && ($attr->{target} || '') eq 'graph')
    {
    $storage->{in_graph} = 1;
    $storage->{cur_graph} = '';
    return;
    }

  if ($element_name =~ /^head/)
    {
    push @{ $storage->{headlines} }, $element_name . ' ';
    $storage->{in_headline} = 1;
    }

  $self->SUPER::_handle_element_start($element_name, $attr);
  }

sub _handle_element_end
  {
  my ($self, $element_name) = @_;

  #print STDERR "end '$element_name'\n";

  my $storage = $self->{_mediawiki_pod_html};

  if ($element_name =~ /^head/)
    {
    $storage->{in_headline} = 0;
    }

  $self->SUPER::_handle_element_end($element_name);
  }

sub _handle_text {
  my ($self, $text) = @_;

  #print STDERR "text '$text'\n";

  my $storage = $self->{_mediawiki_pod_html};
  if ($storage->{in_headline})
    {
    $storage->{headlines}->[-1] .= $text;
    }
  if ($storage->{in_graph})
    {
    $storage->{cur_graph} .= $text;
    return;
    }
  if ($storage->{in_x})
    {
    my $url = $storage->{search};
    my $t = $text;
    $t =~ s/&/&mp;/;
    $t =~ s/'/&squot;/;
    if ($url =~ /##KEYWORD##/)
      {
      $url =~ s/##KEYWORD##/$t/g;
      }
    else
      {
      $url .= $t;
      }
    $self->_my_output( "<a class='keyword' href='$url'>$text</a>" );
    return;
    }

  $self->SUPER::_handle_text($text);
  }

sub get_headlines
  {
  my $self = shift;

  my $storage = $self->{_mediawiki_pod_html};
  $storage->{headlines};
  }

sub keyword_search_url
  {
  my $self = shift;

  my $storage = $self->{_mediawiki_pod_html};
  $storage->{search} = $_[0] if defined $_[0];
  $storage->{search};
  }

sub _my_output
  {
  my $self = shift;

  print {$self->{'output_fh'}} $_[0];
  }

1;

__END__

=pod

=head1 NAME

Mediawiki::POD::HTML - a subclass to catch X keywords and =head lines

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

=head2 keyword_search_url()

Get/set the URL that is used to link keywords defined with C<< X&lt;&gt; >>
to a search engine. 

If the URL contains a text C<##KEYWORD##>, then this text will be replaced
with the actual keyword. Otherwise, the keyword is simple appended to the URL.

The default search URL is:

  	http://cpan.uwinnipeg.ca/search?query=##KEYWORD##

Examples:

	# External search engine
	$parser->keyword_search_url('http://search.cpan.org/perldoc?');

	# will generate URLs like "example", perfect for relative links
	$parser->keyword_search_url('');

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms of the GPL.

See the LICENSE file for information.

=head1 AUTHOR

(c) by Tels bloodgate.com 2007

=head1 SEE ALSO

L<http://bloodgate.com/wiki/>.

=cut
