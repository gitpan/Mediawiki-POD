#!/usr/bin/perl -w

# some basic tests of Mediawiki::POD::HTML
use Test::More;

BEGIN
  {
  plan tests => 3;
  chdir 't' if -d 't';

  use lib '../lib';

  use_ok (qw/ Mediawiki::POD::HTML /);
  }

can_ok ( 'Mediawiki::POD::HTML', qw/
  new
  get_headlines
  /);

my $pod = Mediawiki::POD::HTML->new();

is (ref($pod), 'Mediawiki::POD::HTML');


