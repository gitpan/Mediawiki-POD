#!/usr/bin/perl -w

# some basic tests of Mediawiki::POD
use Test::More;

BEGIN
  {
  plan tests => 3;
  chdir 't' if -d 't';

  use lib '../lib';

  use_ok (qw/ Mediawiki::POD /);
  }

can_ok ( 'Mediawiki::POD', qw/
  new
  as_html
  /);

my $pod = Mediawiki::POD->new();

is (ref($pod), 'Mediawiki::POD');


