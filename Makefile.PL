
# We need at least Perl 5.8.1 for proper Unicode support
require 5.8.1;
use strict;

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# The name of your distribution
name		'mediawiki-pod';

# Get most of the details from the primary module
version		0.02;
abstract	'Convert POD to HTML inside Mediawiki';

requires	'Scalar::Util'	=> 1.13;
requires	'perl'		=> 5.008001;
requires	'Pod::Simple'	=> 3.04;

build_requires	'Test::More'	=> 0.42;

license		'gpl';

author		'Tels <nospam-abuse@bloodgate.com>';

# Do not index these
no_index	directory	=> 'extensions';

# Generate the Makefile
WriteAll;
