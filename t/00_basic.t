#!/usr/bin/perl -w

# some basic tests of podcnv

use Test::More;

my $out;

BEGIN
  {
  plan tests => 1;
  chdir 't' if -d 't';

  use File::Spec;

  }

my $cmd = File::Spec->catdir( File::Spec->updir(),'extensions', 'podcnv' );

$cmd = 'perl ' . $cmd if $^O =~ /mswin/;

my $rc = `$cmd`;
like ($rc, qr/Usage:/, 'usage instruction');

