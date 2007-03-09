package Mediawiki::POD;

our $VERSION = '0.03';

use strict;
use Pod::Simple::HTML;
use Mediawiki::POD::HTML;

sub new
  {
  my $class = shift;

  my $self = bless {}, $class;

  $self;
  }

sub as_html
  {
  my ($self, $input) = @_;

  my $parser = Mediawiki::POD::HTML->new();

  my ($html, $headlines);

  $parser->output_string( \$html );

  $parser->parse_string_document( $input );

  # remove the unwanted HTML sections
  $html =~ s/<head>(.|\n)*<\/head>//;
  $html =~ s/<!--(.|\n)*?-->//g;

  $html =~ s/<\/?(html|body).*?>//g;

  # clean up some crazy tags
  # converting "<code lang='und' xml:lang='und'>" to "<code>
  $html =~ s/<(pre|code|p)\s.*?>/<$1>/g;

  # insert a class for <a name="">
  $html =~ s/<a name="/<a class="u" name="/g;

  # make it readable again :)
  $html =~ s/\&#39;/'/g;

  # convert newlines between <pre> tags to <br>
  # remove all new lines and tabs
  $html = $self->_parse_output($html);

  $html = $self->_generate_toc( $parser->get_headlines() ) . $html;

  # return the result
  $html;
  };

###########################################################################
# We need to remove all new lines, other Mediawiki will insert spurious
# linebreaks. However, inside <pre></pre> we need to replace them with
# <br> so that verbatim sections render properly. A nested regexp could
# solve this, but is not possible. So we implement a very basic parser
# that recognizes three things: <tag>, </tag>, anything else.

# This routine assumes that the <pre> tags are not nested.

sub _parse_output
  {
  my ($self, $input) = @_;

  my $in_pre = 0;

  my $qr_tag = qr/^(<\w+(.|\n)*?>)/;
  my $qr_end_tag = qr/^(<\/\w+>)/;
  my $qr_else = qr/^((?:.|\n)*?)(<|\z)/;

  my $output = '';
  while (length($input) > 0)
    {
    # math the start of the input, and remove the matching part
    if ($input =~ $qr_tag)
      {
      $input =~ s/$qr_tag//;
      my $tag = $1;
      $tag =~ s/[\n\r\t]/ /g;
      $output .= $tag;
      if ($tag =~ /^<pre.*?>/i)
        {
	$in_pre++;
	}
      }
    elsif ($input =~ $qr_end_tag)
      {
      $input =~ s/$qr_end_tag//;
      my $tag = $1;
      $tag =~ s/[\n\r\t]/ /g;
      $output .= $tag;
      if ($tag =~ /^<\/pre.*?>/i)
        {
	$in_pre--;
	}
      }
    else
      {
      $input =~ s/$qr_else/$2/;
      # remove newlines
      my $else = $1;
      if ($in_pre > 0)
        {
        # also remove excessive leading whitespace
        $else =~ s/[\n\r\t]\s*/<br> /g;
        $else =~ s/^\s*/ /;
        }
      else
        {
        $else =~ s/[\n\r\t]/ /g;
        }
      $output .= $else;
      }
    }  
  $output;
  }

sub _generate_toc
  {
  my ($self, $headlines) = @_;

  my $toc = '<table id="toc" class="toc" summary="Contents"><tr><td><div id="toctitle"><h2>Contents</h2></div>';
  $toc .= "\n<ul>\n";

  my $level = 1;
  my @cur_nr = ( 0 );
  for my $headline (@$headlines)
    {
    $headline =~ /^head([1-9]) (.*)/;

    my $cur_level = $1;
    my $txt = $2;
    #print STDERR "$headline $cur_level $level\n";

    # we enter a scope
    if ($cur_level > $level)
      {
      push @cur_nr, 0;
      $toc .= '<ul>';
      }
    elsif ($cur_level < $level)
      {
      pop @cur_nr;
      $toc .= '</ul>';
      }
    $cur_nr[-1]++;
    my $tnr = join ('.', @cur_nr);
    $toc .= "<li class='toclevel-$cur_level'><a href=\"#$txt\"><span class='tocnumber'>$tnr</span> <span class='toctext'>$txt</span></a></li>";
    $level = $cur_level;
    }

  $toc .= "</ul></td></tr></table>\n";
  $toc .= '<script type="text/javascript"> if (window.showTocToggle) { var tocShowText = "show"; var tocHideText = "hide"; showTocToggle(); } </script>';

  $toc =~ s/[\n\r\t]/ /g;
  $toc;
  }

1;

__END__

=pod

=head1 NAME

Mediawiki::POD - convert POD to HTML suitable for a MediaWiki wiki

=head1 SYNOPSIS

	use Mediawiki::POD;
	
	my $converter = Mediawiki::POD->new();

	my $html = $converter->as_thml($POD);

=head1 DESCRIPTION

Turns a given POD (Plain Old Documentation) into HTML code.

=head1 VERSIONS

Please see the CHANGES file for a complete version history.

=head1 METHODS

=head2 new()

	my $converter = Mediawiki::POD->new();

Create a new converter object.

=head2 as_html()

	my $html = $converter->as_html( $pod_text);

Take the given POD text and return HTML suitable for embedding into
an Mediawiki page.

The returned HTML contains no newlines (as these would confuse the
Mdiawiki parser) and a table of contents.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms of the GPL.

See the LICENSE file for information.

=head1 AUTHOR

(c) by Tels bloodgate.com 2007

=head1 SEE ALSO

L<http://bloodgate.com/wiki/>.

=cut
